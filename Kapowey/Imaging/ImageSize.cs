using System;

namespace Kapowey.Imaging
{
    [Serializable]
    public sealed class ImageSize : IImageSize
    {
        public short Height { get; set; }

        public short Width { get; set; }

        public ImageSize()
        {
            Height = 80;
            Width = 80;
        }
    }
}