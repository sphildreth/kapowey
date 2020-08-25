using System;

namespace Kapowey.Models.API.Entities
{
    [Serializable]
    public sealed class Grade : GradeInfo
    {
        public string Notes { get; set; }
    }
}