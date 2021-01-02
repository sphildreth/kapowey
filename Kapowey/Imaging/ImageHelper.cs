using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats;
using SixLabors.ImageSharp.Processing;
using System;
using System.Diagnostics;
using System.IO;

namespace Kapowey.Imaging
{
    public static class ImageHelper
    {
        public static byte[] ResizeImage(byte[] imageBytes, int width, int height) => ImageHelper.ResizeImage(imageBytes,
                                                                                                              width,
                                                                                                              height,
                                                                                                              false).Item2;
        /// <summary>
        /// Resize a given image to given dimensions if needed
        /// </summary>
        /// <param name="imageBytes">Image bytes to resize</param>
        /// <param name="width">Resize to width</param>
        /// <param name="height">Resize to height</param>
        /// <param name="forceResize">Force resize</param>
        /// <returns>Tuple with bool for did resize and byte array of image</returns>
        public static Tuple<bool, byte[]> ResizeImage(byte[] imageBytes,
                                                      int width,
                                                      int height,
                                                      bool? forceResize = false)
        {
            if (imageBytes == null)
            {
                return null;
            }
            try
            {
                using (var outStream = new MemoryStream())
                {
                    var resized = false;
                    IImageFormat imageFormat = null;
                    using (var image = SixLabors.ImageSharp.Image.Load(imageBytes, out imageFormat))
                    {
                        var doForce = forceResize ?? false;
                        if (doForce || image.Width > width || image.Height > height)
                        {
                            int newWidth, newHeight;
                            if (doForce)
                            {
                                newWidth = width;
                                newHeight = height;
                            }
                            else
                            {
                                float aspect = image.Width / (float)image.Height;
                                if (aspect < 1)
                                {
                                    newWidth = (int)(width * aspect);
                                    newHeight = (int)(newWidth / aspect);
                                }
                                else
                                {
                                    newHeight = (int)(height / aspect);
                                    newWidth = (int)(newHeight * aspect);
                                }
                            }
                            image.Mutate(ctx => ctx.Resize(newWidth, newHeight));
                            resized = true;
                        }
                        image.Save(outStream, imageFormat);
                    }
                    return new Tuple<bool, byte[]>(resized, outStream.ToArray());
                }
            }
            catch (Exception ex)
            {
                Trace.WriteLine($"Error Resizing Image [{ex}]", "Warning");
            }
            return null;
        }
    }
}