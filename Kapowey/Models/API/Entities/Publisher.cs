using FluentValidation;
using NodaTime;
using System;
using System.ComponentModel.DataAnnotations;

namespace Kapowey.Models.API.Entities
{
    [Serializable]
    public sealed class Publisher : PublisherInfo
    {
        [Required]
        [StringLength(3)]
        public string CountryCode { get; set; }

        public override Instant? CreatedDate { get; set; }

        public int? GcdId { get; set; }

        public override Instant? ModifiedDate { get; set; }

        public override Instant? ReviewedDate { get; set; }

        public int? YearBegan { get; set; }

        public int? YearEnd { get; set; }
    }

    public sealed class PublisherValidator : AbstractValidator<Publisher>
    {
        public PublisherValidator()
        {
            RuleFor(p => p.Name)
                .NotEmpty()
                .MaximumLength(500)
                .WithMessage("Please provider a valid Publisher name");

            RuleFor(p => p.ShortName)
                .NotEmpty()
                .MaximumLength(10)
                .WithMessage("Please provide a valid Publisher short name");

            RuleFor(p => p.CountryCode)
                .NotEmpty()
                .MaximumLength(3)
                .WithMessage("Please provide a valid Publisher country code");
        }
    }
}