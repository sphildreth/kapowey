using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Kapowey.Caching
{
    public interface ICacheSerializer
    {
        string Serialize(object o);
        TOut Deserialize<TOut>(string s);
    }
}
