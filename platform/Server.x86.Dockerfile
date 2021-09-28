FROM mcr.microsoft.com/dotnet/sdk:5.0 AS builder
WORKDIR /app

COPY *.sln .
COPY ./libs/EmpoweredSignalR/EmpoweredSignalR.csproj ./libs/EmpoweredSignalR/
COPY ./Shared/Shared.csproj ./Shared/
COPY ./Server/Server.csproj ./Server/

RUN dotnet restore Server

COPY . .
RUN dotnet publish Server -c release -o /output

FROM mcr.microsoft.com/dotnet/aspnet:5.0-buster-slim as runner
WORKDIR /app
EXPOSE 80
COPY --from=builder /output ./
ENTRYPOINT ["./Server"]