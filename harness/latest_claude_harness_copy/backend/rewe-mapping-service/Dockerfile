FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

COPY ReweMappingService.sln .
COPY src/ReweMappingService/ReweMappingService.csproj src/ReweMappingService/
COPY tests/ReweMappingService.Tests/ReweMappingService.Tests.csproj tests/ReweMappingService.Tests/
RUN dotnet restore

COPY src/ src/
COPY tests/ tests/
RUN dotnet build --no-restore -c Release

FROM build AS test
RUN dotnet test --no-build -c Release --logger "console;verbosity=normal"

FROM build AS publish
RUN dotnet publish src/ReweMappingService/ReweMappingService.csproj --no-build -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ReweMappingService.dll"]
