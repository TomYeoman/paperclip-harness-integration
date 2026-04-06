using ReweMappingService.Models;

namespace ReweMappingService.Services;

public interface IStoreDocumentRepository
{
    StoreDocument? FindByStoreId(string storeId);
}
