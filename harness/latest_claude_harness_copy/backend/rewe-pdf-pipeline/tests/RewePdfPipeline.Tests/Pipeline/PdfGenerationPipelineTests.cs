using RewePdfPipeline.Domain;
using RewePdfPipeline.Pipeline;
using RewePdfPipeline.Tests.Fakes;
using Xunit;

namespace RewePdfPipeline.Tests.Pipeline;

public sealed class PdfGenerationPipelineTests
{
    private const string TestStoreId = "REWE_TEST_999";
    private const string TestStoreName = "REWE Test Store 999";
    private const string TestStoreAddress = "Teststraße 1, 10115 Berlin";

    private static PdfGenerationPipeline BuildPipeline(
        FakeRestaurantServiceClient? restaurant = null,
        FakePdfGenerator? pdfGenerator = null,
        FakeCloudinaryClient? cloudinary = null,
        FakeMappingRegistrar? mapping = null,
        SpyObservabilityLogger? logger = null)
    {
        return new PdfGenerationPipeline(
            restaurant ?? new FakeRestaurantServiceClient(
                new StoreMetadata(TestStoreId, TestStoreName, TestStoreAddress)),
            pdfGenerator ?? new FakePdfGenerator(),
            cloudinary ?? new FakeCloudinaryClient(),
            mapping ?? new FakeMappingRegistrar(),
            logger ?? new SpyObservabilityLogger()
        );
    }

    [Fact]
    public async Task S11_PdfContainsStoreNameAndAddress_FromRestaurantService()
    {
        var pdfGenerator = new FakePdfGenerator();
        var pipeline = BuildPipeline(pdfGenerator: pdfGenerator);

        await pipeline.RunAsync(TestStoreId);

        Assert.NotNull(pdfGenerator.LastStore);
        Assert.Equal(TestStoreName, pdfGenerator.LastStore.StoreName);
        Assert.Equal(TestStoreAddress, pdfGenerator.LastStore.StoreAddress);
    }

    [Fact]
    public async Task S11_PdfUploadedToCloudinary_WithStoreSpecificFilename()
    {
        var cloudinary = new FakeCloudinaryClient();
        var pipeline = BuildPipeline(cloudinary: cloudinary);

        await pipeline.RunAsync(TestStoreId);

        Assert.Equal(TestStoreId, cloudinary.LastUploadedStoreId);
        Assert.NotNull(cloudinary.LastUploadedBytes);
        Assert.True(cloudinary.LastUploadedBytes.Length > 0);
    }

    [Fact]
    public async Task S11_PdfUrlRegisteredInMappingService_AfterGeneration()
    {
        var cloudinary = new FakeCloudinaryClient();
        var mapping = new FakeMappingRegistrar();
        var pipeline = BuildPipeline(cloudinary: cloudinary, mapping: mapping);

        await pipeline.RunAsync(TestStoreId);

        Assert.Equal(TestStoreId, mapping.LastRegisteredStoreId);
        Assert.NotNull(mapping.LastRegisteredPdfUrl);
        Assert.True(mapping.LastRegisteredPdfUrl.Length > 0);
    }

    [Fact]
    public async Task S11_ObservabilityEventFires_WithAllRequiredFields()
    {
        var logger = new SpyObservabilityLogger();
        var cloudinary = new FakeCloudinaryClient();
        var restaurant = new FakeRestaurantServiceClient(
            new StoreMetadata(TestStoreId, TestStoreName, TestStoreAddress),
            responseMs: 123);

        var pipeline = BuildPipeline(restaurant: restaurant, cloudinary: cloudinary, logger: logger);

        await pipeline.RunAsync(TestStoreId);

        Assert.True(logger.WasCalled);
        Assert.Equal(TestStoreId, logger.StoreId);
        Assert.Equal(TestStoreName, logger.StoreName);
        Assert.Equal(TestStoreAddress, logger.StoreAddress);
        Assert.True(logger.PdfSizeBytes > 0);
        Assert.NotNull(logger.PdfUrl);
        Assert.Equal(123, logger.RestaurantServiceResponseMs);
    }

    [Fact]
    public async Task S11_PipelineFails_WhenRestaurantServiceReturnsEmptyStoreName()
    {
        var restaurant = new FakeRestaurantServiceClient(
            new StoreMetadata(TestStoreId, string.Empty, TestStoreAddress));
        var pipeline = BuildPipeline(restaurant: restaurant);

        await Assert.ThrowsAsync<InvalidOperationException>(() => pipeline.RunAsync(TestStoreId));
    }

    [Fact]
    public async Task S11_PipelineFails_WhenRestaurantServiceReturnsEmptyStoreAddress()
    {
        var restaurant = new FakeRestaurantServiceClient(
            new StoreMetadata(TestStoreId, TestStoreName, string.Empty));
        var pipeline = BuildPipeline(restaurant: restaurant);

        await Assert.ThrowsAsync<InvalidOperationException>(() => pipeline.RunAsync(TestStoreId));
    }

    [Fact]
    public async Task S11_PipelineFails_WhenRestaurantServiceReturnsNullMetadata()
    {
        var restaurant = new FakeRestaurantServiceClient(metadata: null);
        var pipeline = BuildPipeline(restaurant: restaurant);

        await Assert.ThrowsAsync<InvalidOperationException>(() => pipeline.RunAsync(TestStoreId));
    }

    [Fact]
    public async Task S11_PipelineThrowsHttpRequestException_WhenRestaurantServiceUnavailable()
    {
        var restaurant = new FakeRestaurantServiceClient(metadata: null, throwUnavailable: true);
        var pipeline = BuildPipeline(restaurant: restaurant);

        // Caller is responsible for retry — pipeline propagates the exception
        await Assert.ThrowsAsync<HttpRequestException>(() => pipeline.RunAsync(TestStoreId));
    }

    [Fact]
    public async Task S11_NoPdfGenerated_WhenRestaurantServiceUnavailable()
    {
        var pdfGenerator = new FakePdfGenerator();
        var restaurant = new FakeRestaurantServiceClient(metadata: null, throwUnavailable: true);
        var pipeline = BuildPipeline(restaurant: restaurant, pdfGenerator: pdfGenerator);

        await Assert.ThrowsAsync<HttpRequestException>(() => pipeline.RunAsync(TestStoreId));

        // PDF generation must not have been called
        Assert.Null(pdfGenerator.LastStore);
    }

    [Fact]
    public async Task S11_ResultContainsPdfUrl_MatchingCloudinaryUploadUrl()
    {
        var cloudinary = new FakeCloudinaryClient("https://res.cloudinary.com/test/raw/upload");
        var pipeline = BuildPipeline(cloudinary: cloudinary);

        var result = await pipeline.RunAsync(TestStoreId);

        Assert.Contains(TestStoreId, result.PdfUrl);
        Assert.StartsWith("https://res.cloudinary.com", result.PdfUrl);
    }

    [Fact]
    public async Task S11_ResultContainsPdfSizeBytes_GreaterThanZero()
    {
        var pipeline = BuildPipeline();

        var result = await pipeline.RunAsync(TestStoreId);

        Assert.True(result.PdfSizeBytes > 0);
    }

    [Fact]
    public async Task S11_ResultContainsRestaurantServiceResponseMs()
    {
        var restaurant = new FakeRestaurantServiceClient(
            new StoreMetadata(TestStoreId, TestStoreName, TestStoreAddress),
            responseMs: 200);
        var pipeline = BuildPipeline(restaurant: restaurant);

        var result = await pipeline.RunAsync(TestStoreId);

        Assert.Equal(200, result.RestaurantServiceResponseMs);
    }
}
