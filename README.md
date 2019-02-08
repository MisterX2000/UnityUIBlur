UI Blur for Unity
==========

![view](https://i.imgur.com/BrBqtRl.png)

Usage
-----

Just add **UIBlur.cs** script to Camera and attach *UIBlurPostEffect* and *UIBlur* material to it.

Properties
----------

![editor](https://i.imgur.com/yUhL3P4.png)

- **Kernel Size** - Bigger kernels produces bigger blur, but are more expensive.

- **Interpolation** - Use if you want to create smooth blurring transition.

- **Downsample** - Controls buffer resolution (0 = no downsampling, 1 = half resolution... etc.).

- **Iterations** - More iterations = bigger blur, but comes at perfomance cost.

- **Gamma Correction** - Enables gamma correction to produce correct blur in Gamma Colorspace. Disable this option if you use Linear Colorspace. 

Credits
-------

Based on https://github.com/PavelDoGreat/Super-Blur
