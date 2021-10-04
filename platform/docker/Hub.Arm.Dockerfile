FROM mcr.microsoft.com/dotnet/sdk:5.0 AS builder
WORKDIR /app

COPY *.sln .
COPY ./libs/EmpoweredSignalR/EmpoweredSignalR.csproj ./libs/EmpoweredSignalR/
COPY ./Shared/Shared.csproj ./Shared/
COPY ./Hub/Hub.csproj ./Hub/

RUN dotnet restore Hub

COPY . .
RUN dotnet publish Hub -c release -o /output -r linux-arm

FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim-arm32v7 as runner
WORKDIR /app
EXPOSE 5000
EXPOSE 1883
COPY --from=builder /output ./
ENTRYPOINT ["./Hub"]