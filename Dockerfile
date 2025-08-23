FROM ghcr.io/foundry-rs/foundry:latest

WORKDIR /app
COPY . .

# Instalamos las dependencias
RUN forge install foundry-rs/forge-std OpenZeppelin/openzeppelin-contracts OpenZeppelin/openzeppelin-contracts-upgradeable --no-commit

# El comando por defecto será ejecutar los tests
CMD ["forge", "test", "-vv"]
