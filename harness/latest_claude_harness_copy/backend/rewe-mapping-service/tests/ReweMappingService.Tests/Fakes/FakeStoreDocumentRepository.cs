using ReweMappingService.Models;
using ReweMappingService.Services;

namespace ReweMappingService.Tests.Fakes;

public class FakeStoreDocumentRepository : IStoreDocumentRepository
{
    private readonly Dictionary<string, StoreDocument> _store = new();

    public void Add(StoreDocument doc) => _store[doc.StoreId] = doc;

    public StoreDocument? FindByStoreId(string storeId)
    {
        _store.TryGetValue(storeId, out var doc);
        return doc;
    }
}
