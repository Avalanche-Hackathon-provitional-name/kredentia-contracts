// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IDocumentNFT.sol";

/**
 * @title PrivacyDocumentToken
 * @dev Implementation of privacy-preserving document certification using EERC20 tokens
 */
contract PrivacyDocumentToken is ERC20, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _documentIds;

    // Estructuras para documentos privados
    struct PrivateDocument {
        bytes32 zkHash;           // Hash de conocimiento cero
        address owner;            // Dirección del propietario encriptada
        uint256 timestamp;        // Timestamp del bloque
        bool verified;            // Estado de verificación ZK
        bytes encryptedMetadata;  // Metadatos del documento encriptados
    }

    // Mappings para almacenamiento privado
    mapping(bytes32 => PrivateDocument) private documents;
    mapping(address => bytes32[]) private userDocuments;
    mapping(bytes32 => bool) private usedNullifiers;

    // Eventos
    event DocumentMinted(bytes32 indexed zkHash, address indexed owner, uint256 timestamp);
    event DocumentVerified(bytes32 indexed zkHash, bool verified);
    event MetadataUpdated(bytes32 indexed zkHash, bytes encryptedMetadata);

    constructor() ERC20("Privacy Document Token", "PDT") Ownable(msg.sender) {}

    /**
     * @dev Mint un nuevo documento privado
     * @param _zkHash Hash ZK del documento
     * @param _encryptedMetadata Metadatos encriptados del documento
     */
    function mintPrivateDocument(
        bytes32 _zkHash,
        bytes calldata _encryptedMetadata
    ) external returns (uint256) {
        require(_zkHash != bytes32(0), "Invalid ZK hash");
        require(documents[_zkHash].owner == address(0), "Document already exists");

        _documentIds.increment();
        uint256 tokenId = _documentIds.current();

        // Crear documento privado
        documents[_zkHash] = PrivateDocument({
            zkHash: _zkHash,
            owner: msg.sender,
            timestamp: block.timestamp,
            verified: false,
            encryptedMetadata: _encryptedMetadata
        });

        userDocuments[msg.sender].push(_zkHash);
        
        // Mint token EERC20
        _mint(msg.sender, 1 * 10**decimals());

        emit DocumentMinted(_zkHash, msg.sender, block.timestamp);
        return tokenId;
    }

    /**
     * @dev Verifica un documento usando prueba ZK
     * @param _zkHash Hash del documento
     * @param _zkProof Prueba de conocimiento cero
     */
    function verifyDocumentZK(
        bytes32 _zkHash,
        bytes calldata _zkProof
    ) external view returns (bool) {
        require(documents[_zkHash].owner != address(0), "Document does not exist");
        // Aquí iría la verificación real de ZK proof
        // Por ahora retornamos true para simulación
        return true;
    }

    /**
     * @dev Obtiene el propietario de un documento
     * @param _zkHash Hash del documento
     */
    function getPrivateDocumentOwner(
        bytes32 _zkHash
    ) external view returns (address) {
        require(documents[_zkHash].owner != address(0), "Document does not exist");
        return documents[_zkHash].owner;
    }

    /**
     * @dev Actualiza los metadatos encriptados de un documento
     * @param _zkHash Hash del documento
     * @param _newEncryptedMetadata Nuevos metadatos encriptados
     */
    function updateEncryptedMetadata(
        bytes32 _zkHash,
        bytes calldata _newEncryptedMetadata
    ) external {
        require(documents[_zkHash].owner == msg.sender, "Not document owner");
        documents[_zkHash].encryptedMetadata = _newEncryptedMetadata;
        emit MetadataUpdated(_zkHash, _newEncryptedMetadata);
    }

    /**
     * @dev Obtiene los documentos de un usuario
     * @param _owner Dirección del usuario
     */
    function getUserDocuments(
        address _owner
    ) external view returns (bytes32[] memory) {
        return userDocuments[_owner];
    }

    /**
     * @dev Obtiene los metadatos encriptados de un documento
     * @param _zkHash Hash del documento
     */
    function getEncryptedMetadata(
        bytes32 _zkHash
    ) external view returns (bytes memory) {
        require(documents[_zkHash].owner != address(0), "Document does not exist");
        return documents[_zkHash].encryptedMetadata;
    }
}
