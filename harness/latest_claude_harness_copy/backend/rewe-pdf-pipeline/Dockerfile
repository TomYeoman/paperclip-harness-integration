FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app

COPY RewePdfPipeline.sln .
COPY src/RewePdfPipeline/RewePdfPipeline.csproj src/RewePdfPipeline/
COPY tests/RewePdfPipeline.Tests/RewePdfPipeline.Tests.csproj tests/RewePdfPipeline.Tests/

RUN dotnet restore

COPY src/ src/
COPY tests/ tests/

RUN dotnet build --no-restore -c Release

FROM build AS test
ENTRYPOINT ["dotnet", "test", "--no-build", "-c", "Release", "--logger", "console;verbosity=normal"]

FROM build AS publish
RUN dotnet publish src/RewePdfPipeline/RewePdfPipeline.csproj --no-build -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/runtime:10.0 AS runtime
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "RewePdfPipeline.dll"]
