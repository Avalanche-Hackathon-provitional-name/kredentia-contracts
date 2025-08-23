// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ZKVerificationRegistry
 * @dev Registro para verificación de pruebas de conocimiento cero
 */
contract ZKVerificationRegistry is Ownable {
    struct ZKProof {
        bytes32 commitment;    // Compromiso ZK
        bytes32 nullifier;     // Nullifier para prevenir doble gasto
        bytes proof;          // Prueba ZK
        bool verified;        // Estado de verificación
        uint256 timestamp;    // Timestamp de la verificación
    }

    // Almacenamiento de pruebas
    mapping(bytes32 => ZKProof) private proofs;
    mapping(bytes32 => bool) private usedNullifiers;

    // Eventos
    event ProofSubmitted(bytes32 indexed commitment, bytes32 indexed nullifier);
    event ProofVerified(bytes32 indexed commitment, bool verified);

    constructor() Ownable(msg.sender) {}

    /**
     * @dev Envía una nueva prueba ZK
     * @param _commitment Compromiso ZK
     * @param _nullifier Nullifier único
     * @param _proof Datos de la prueba
     */
    function submitZKProof(
        bytes32 _commitment,
        bytes32 _nullifier,
        bytes calldata _proof
    ) external {
        require(_commitment != bytes32(0), "Invalid commitment");
        require(_nullifier != bytes32(0), "Invalid nullifier");
        require(!usedNullifiers[_nullifier], "Nullifier already used");
        require(proofs[_commitment].commitment == bytes32(0), "Proof already exists");

        proofs[_commitment] = ZKProof({
            commitment: _commitment,
            nullifier: _nullifier,
            proof: _proof,
            verified: false,
            timestamp: block.timestamp
        });

        usedNullifiers[_nullifier] = true;
        emit ProofSubmitted(_commitment, _nullifier);
    }

    /**
     * @dev Verifica una prueba ZK
     * @param _commitment Compromiso a verificar
     */
    function verifyZKProof(
        bytes32 _commitment
    ) external view returns (bool) {
        require(proofs[_commitment].commitment != bytes32(0), "Proof does not exist");
        // Aquí iría la verificación real del circuito ZK
        // Por ahora retornamos true para simulación
        return proofs[_commitment].verified;
    }

    /**
     * @dev Actualiza el estado de verificación de una prueba (solo owner)
     * @param _commitment Compromiso a actualizar
     * @param _verified Nuevo estado de verificación
     */
    function setProofVerification(
        bytes32 _commitment,
        bool _verified
    ) external onlyOwner {
        require(proofs[_commitment].commitment != bytes32(0), "Proof does not exist");
        proofs[_commitment].verified = _verified;
        emit ProofVerified(_commitment, _verified);
    }

    /**
     * @dev Obtiene los detalles de una prueba
     * @param _commitment Compromiso de la prueba
     */
    function getProofDetails(
        bytes32 _commitment
    ) external view returns (
        bytes32 nullifier,
        bool verified,
        uint256 timestamp
    ) {
        require(proofs[_commitment].commitment != bytes32(0), "Proof does not exist");
        ZKProof memory proof = proofs[_commitment];
        return (proof.nullifier, proof.verified, proof.timestamp);
    }

    /**
     * @dev Verifica si un nullifier ha sido usado
     * @param _nullifier Nullifier a verificar
     */
    function isNullifierUsed(
        bytes32 _nullifier
    ) external view returns (bool) {
        return usedNullifiers[_nullifier];
    }
}
