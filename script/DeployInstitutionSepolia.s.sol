// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/DocumentFactory.sol";

contract DeployInstitutionSepolia is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        // Factory address from Sepolia deployment
        address factoryAddress = 0x7fe5708061E76C271a1A9466f73D7667ed0C7Ddd;
        
        console.log("=== DEPLOYING INSTITUTION TO SEPOLIA ===");
        console.log("Deployer address:", deployer);
        console.log("Chain ID:", block.chainid);
        console.log("Using Factory at:", factoryAddress);
        
        vm.startBroadcast(deployerPrivateKey);
        
        DocumentFactory factory = DocumentFactory(factoryAddress);
        
        // Configuración de la institución
        string memory institutionName = "Universidad Nacional Sepolia";
        string memory nftName = "UNS Document NFTs";
        string memory nftSymbol = "UNSDOC";
        
        console.log("Deploying institution system...");
        console.log("Institution:", institutionName);
        console.log("NFT Name:", nftName);
        console.log("NFT Symbol:", nftSymbol);
        
        // Deploy del sistema institucional usando el deployer como admin
        DocumentFactory.DeployedContracts memory contracts = factory.deployInstitutionSystem(
            institutionName,
            nftName,
            nftSymbol,
            deployer  // usar el deployer como admin de la institución
        );
        
        vm.stopBroadcast();
        
        console.log("\n=== INSTITUTION DEPLOYED ===");
        console.log("InstitutionDAO:", contracts.institutionDAO);
        console.log("SignatureManager:", contracts.signatureManager);
        console.log("DocumentNFT:", contracts.documentNFT);
        console.log("DocumentWorkflow:", contracts.documentWorkflow);
        
        // Actualizar el archivo JSON con la información de la institución
        string memory contractsJson = string(
            abi.encodePacked(
                '{\n',
                '  "network": "sepolia",\n',
                '  "chainId": ', vm.toString(block.chainid), ',\n',
                '  "deployedAt": ', vm.toString(block.timestamp), ',\n',
                '  "deployer": "', vm.toString(deployer), '",\n',
                '  "admin": "', vm.toString(deployer), '",\n',
                '  "factory": "', vm.toString(factoryAddress), '",\n',
                '  "templates": {\n',
                '    "institutionDAO": "0x422478a088ce4d9D9418d4D2C9D99c78fC23393f",\n',
                '    "signatureManager": "0x44b89ba09a381F3b598a184A90F039948913dC72",\n',
                '    "documentNFT": "0x8bbDDc3fcb74CdDB7050552b4DE01415C9966133",\n',
                '    "documentWorkflow": "0x2212FBb6C244267c23a5710E7e6c4769Ea423beE"\n',
                '  },\n',
                '  "institution": {\n',
                '    "name": "', institutionName, '",\n',
                '    "nftName": "', nftName, '",\n',
                '    "nftSymbol": "', nftSymbol, '",\n',
                '    "dao": "', vm.toString(contracts.institutionDAO), '",\n',
                '    "signatureManager": "', vm.toString(contracts.signatureManager), '",\n',
                '    "documentNFT": "', vm.toString(contracts.documentNFT), '",\n',
                '    "documentWorkflow": "', vm.toString(contracts.documentWorkflow), '"\n',
                '  }\n',
                '}'
            )
        );

        vm.writeFile("./deployed-contracts-sepolia.json", contractsJson);
        console.log("Contract data updated in deployed-contracts-sepolia.json");
    }
}
