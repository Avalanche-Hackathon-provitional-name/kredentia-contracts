// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IPrivacyDocumentToken
 * @dev Interfaz para el token de documentos privados
 */
interface IPrivacyDocumentToken {
    /**
     * @dev Estructura para documentos privados
     */
    struct PrivateDocument {
        bytes32 zkHash;           // Hash de conocimiento cero
        address owner;            // Dirección del propietario encriptada
        uint256 timestamp;        // Timestamp del bloque
        bool verified;            // Estado de verificación ZK
        bytes encryptedMetadata;  // Metadatos del documento encriptados
    }

    /**
     * @dev Eventos emitidos por el contrato
     */
    event DocumentMinted(bytes32 indexed zkHash, address indexed owner, uint256 timestamp);
    event DocumentVerified(bytes32 indexed zkHash, bool verified);
    event MetadataUpdated(bytes32 indexed zkHash, bytes encryptedMetadata);

    /**
     * @dev Mint un nuevo documento privado
     * @param _zkHash Hash ZK del documento
     * @param _encryptedMetadata Metadatos encriptados del documento
     */
    function mintPrivateDocument(
        bytes32 _zkHash,
        bytes calldata _encryptedMetadata
    ) external returns (uint256);

    /**
     * @dev Verifica un documento usando prueba ZK
     * @param _zkHash Hash del documento
     * @param _zkProof Prueba de conocimiento cero
     */
    function verifyDocumentZK(
        bytes32 _zkHash,
        bytes calldata _zkProof
    ) external view returns (bool);

    /**
     * @dev Obtiene el propietario de un documento
     * @param _zkHash Hash del documento
     */
    function getPrivateDocumentOwner(
        bytes32 _zkHash
    ) external view returns (address);

    /**
     * @dev Actualiza los metadatos encriptados de un documento
     * @param _zkHash Hash del documento
     * @param _newEncryptedMetadata Nuevos metadatos encriptados
     */
    function updateEncryptedMetadata(
        bytes32 _zkHash,
        bytes calldata _newEncryptedMetadata
    ) external;

    /**
     * @dev Obtiene los documentos de un usuario
     * @param _owner Dirección del usuario
     */
    function getUserDocuments(
        address _owner
    ) external view returns (bytes32[] memory);

    /**
     * @dev Obtiene los metadatos encriptados de un documento
     * @param _zkHash Hash del documento
     */
    function getEncryptedMetadata(
        bytes32 _zkHash
    ) external view returns (bytes memory);
}
