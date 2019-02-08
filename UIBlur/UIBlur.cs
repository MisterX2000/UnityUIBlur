using UnityEngine;

namespace UIBlur
{
    [RequireComponent(typeof(Camera))]
    [AddComponentMenu("UI/Effects/Blur", -1)]
    [ExecuteInEditMode]
    public class UIBlur : MonoBehaviour
	{
        protected static class Uniforms
        {
            public static readonly int _Radius = Shader.PropertyToID("_Radius");
            public static readonly int _BackgroundTexture = Shader.PropertyToID("_BlurTexture");
        }

        public enum BlurKernelSize
        {
            Small,
            Medium,
            Big
        }

        public BlurKernelSize kernelSize = BlurKernelSize.Small;

        [Range(0f, 1f)]
        public float interpolation = 1f;

        [Range(0, 4)]
        public int downsample = 1;

        [Range(1, 8)]
        public int iterations = 1;

        public bool gammaCorrection = true;

        public Material blurMaterial;

        public Material UIMaterial;

        void OnRenderImage (RenderTexture source, RenderTexture destination) 
		{
			if (UIMaterial == null) return;

			int tw = source.width >> downsample;
			int th = source.height >> downsample;

			var rt = RenderTexture.GetTemporary(tw, th, 0, source.format);

			Graphics.Blit(source, rt);// TODO делает черным UI

            Blur(rt, rt);
            UIMaterial.SetTexture(Uniforms._BackgroundTexture, rt);
            Graphics.Blit(source, destination);// TODO делает экран черным

            RenderTexture.ReleaseTemporary(rt);
		}

        protected void Blur(RenderTexture source, RenderTexture destination)
        {
            if (gammaCorrection)
            {
                Shader.EnableKeyword("GAMMA_CORRECTION");
            }
            else
            {
                Shader.DisableKeyword("GAMMA_CORRECTION");
            }

            int kernel = 0;

            switch (kernelSize)
            {
                case BlurKernelSize.Small:
                    kernel = 0;
                    break;
                case BlurKernelSize.Medium:
                    kernel = 2;
                    break;
                case BlurKernelSize.Big:
                    kernel = 4;
                    break;
            }

            var rt2 = RenderTexture.GetTemporary(source.width, source.height, 0, source.format);

            for (int i = 0; i < iterations; i++)
            {
                // helps to achieve a larger blur
                float radius = (float)i * interpolation + interpolation;
                blurMaterial.SetFloat(Uniforms._Radius, radius);

                Graphics.Blit(source, rt2, blurMaterial, 1 + kernel);
                source.DiscardContents();

                // is it a last iteration? If so, then blit to destination
                if (i == iterations - 1)
                {
                    Graphics.Blit(rt2, destination, blurMaterial, 2 + kernel);
                }
                else
                {
                    Graphics.Blit(rt2, source, blurMaterial, 2 + kernel);
                    rt2.DiscardContents();
                }
            }

            RenderTexture.ReleaseTemporary(rt2);
        }

    }
}
