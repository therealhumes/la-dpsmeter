FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build-backend
WORKDIR /app

COPY . ./

RUN dotnet restore
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:6.0

# Install libpcap with remote control support
RUN apt-get update \
    && apt-get install flex bison wget build-essential -y --no-install-recommends \
    && apt-get clean

RUN wget https://www.tcpdump.org/release/libpcap-1.10.1.tar.gz && tar xzf libpcap-1.10.1.tar.gz \
    && cd libpcap-1.10.1 \
    && ./configure --enable-remote && make install

WORKDIR /app
COPY --from=build-backend /app/out .
COPY ./bin .
ENTRYPOINT ["dotnet", "LostArkLogger.dll"]