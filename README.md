HdrpBlitter
-----------

Blit-only custom render classes for HDRP.

![gif](https://i.imgur.com/SsGMDnv.gif)

This example shows how to use the custom render feature of HDRP to do a simple
full screen blit. By using this feature, it actually only do a single blit
skipping almost every part of the rendering pipeline, which is faster than
doing the same thing with a big quad and a normal camera.

At the moment, this example contains the following custom renders:

- SimpleBlit - Simply copy a source texture to the target.
- CrossFadeBlit - Blends two sources into the target.
- GlitchBlit - Apply a glitch effect and outputs to the target.
