using Kapowey.Models.API;
using Xunit;

namespace Kapowey.Tests
{
    public class RequestFilterTests
    {

        [Fact]
        public void RequestFilterCleanProp()
        {
            var request = new RequestFilter
            {
                AndOr = RequestFilterAndOr.And,
                Operation = "Equals",
                Prop = "; DROP ALL TABLES; --",
                Value = 15
            };
            Assert.Throws<RequestException>(() => request.FilterSql());
        }

        [Fact]
        public void RequestFilterCleanValue()
        {
            var request = new RequestFilter
            {
                AndOr = RequestFilterAndOr.And,
                Operation = "Equals",
                Prop = "UserName",
                Value = "; DROP ALL TABLES; --"
            };
            Assert.Throws<RequestException>(() => request.FilterSql());

            request = new RequestFilter
            {
                AndOr = RequestFilterAndOr.And,
                Operation = "Equals",
                Prop = "UserName",
                Value = ";DROP ALL TABLES; --"
            };
            Assert.Throws<RequestException>(() => request.FilterSql());

            request = new RequestFilter
            {
                AndOr = RequestFilterAndOr.And,
                Operation = "Equals",
                Prop = "UserName",
                Value = ";drop table 'batman'; --"
            };
            Assert.Throws<RequestException>(() => request.FilterSql());

            request = new RequestFilter
            {
                AndOr = RequestFilterAndOr.And,
                Operation = "Equals",
                Prop = "UserName",
                Value = ";update table set 'isactive' = 0; --"
            };
            Assert.Throws<RequestException>(() => request.FilterSql());
        }

        [Fact]
        public void RequestFilterEqualToSingleNumber()
        {
            var request = new RequestFilter
            {
                AndOr = RequestFilterAndOr.And,
                Operation = "Equals",
                Prop = "UserId",
                Value = 15
            };
            Assert.Equal("UserId == 15", request.FilterSql());
        }

        [Fact]
        public void RequestFilterGreaterThanToSingleNumber()
        {
            var request = new RequestFilter
            {
                AndOr = RequestFilterAndOr.And,
                Operation = "GreaterThan",
                Prop = "UserId",
                Value = 15
            };
            Assert.Equal("UserId > 15", request.FilterSql());
        }

        [Fact]
        public void RequestFilterLessThanToSingleNumber()
        {
            var request = new RequestFilter
            {
                AndOr = RequestFilterAndOr.And,
                Operation = "LessThan",
                Prop = "UserId",
                Value = 15
            };
            Assert.Equal("UserId < 15", request.FilterSql());
        }

        [Fact]
        public void RequestBetweenNumbers()
        {
            var request = new RequestFilter
            {
                AndOr = RequestFilterAndOr.And,
                Operation = "LessThan",
                Prop = "UserId",
                Value = 15,
                Value2 = 17
            };
            Assert.Equal("UserId >= 15 AND UserId <= 17", request.FilterSql());
        }

        [Fact]
        public void RequestFilterEqualToSingleString()
        {
            var request = new RequestFilter
            {
                AndOr = RequestFilterAndOr.And,
                Operation = "Equals",
                Prop = "UserName",
                Value = "steven"
            };
            Assert.Equal("UserName == \"steven\"", request.FilterSql());
        }

        [Fact]
        public void RequestFilterStartsWithSingleString()
        {
            var request = new RequestFilter
            {
                AndOr = RequestFilterAndOr.And,
                Operation = "StartsWith",
                Prop = "UserName",
                Value = "ste"
            };
            Assert.Equal("UserName LIKE \"%ste\"", request.FilterSql());
        }

        [Fact]
        public void RequestFilterEndsWithSingleString()
        {
            var request = new RequestFilter
            {
                AndOr = RequestFilterAndOr.And,
                Operation = "EndsWith",
                Prop = "UserName",
                Value = "ste"
            };
            Assert.Equal("UserName LIKE \"ste%\"", request.FilterSql());
        }

        [Fact]
        public void RequestFilterLikeSingleString()
        {
            var request = new RequestFilter
            {
                AndOr = RequestFilterAndOr.And,
                Operation = "contains",
                Prop = "UserName",
                Value = "ste"
            };
            Assert.Equal("UserName LIKE \"%ste%\"", request.FilterSql());
        }
    }
}