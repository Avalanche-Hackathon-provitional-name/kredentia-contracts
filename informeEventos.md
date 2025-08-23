# 🔐 EIP-712 en el Proyecto de Certificación Digital

## 📋 **¿Qué es EIP-712 y Por Qué se Usa?**

EIP-712 (Ethereum Improvement Proposal 712) es un estándar para firmas digitales estructuradas que permite:

1. **Firmas legibles para humanos** en lugar de hash hexadecimales
2. **Prevención de ataques de replay** entre diferentes contratos
3. **Validación criptográfica** de la integridad del documento
4. **Interoperabilidad** con wallets como MetaMask

---

## 🔍 **Implementación de EIP-712 en el Proyecto** ### **1. Configuración EIP-712**

```solidity
// src/DocumentSignatureManager.sol - Líneas 12, 18-20

contract DocumentSignatureManager is Initializable, EIP712Upgradeable, AccessControlUpgradeable {
    
    // TypeHash define la estructura de datos firmada
    bytes32 private constant DOCUMENT_SIGNATURE_TYPEHASH = keccak256(
        "DocumentSignature(uint256 documentId,address signer,bytes32 role,bytes32 documentHash,uint256 deadline)"
    );
```

**¿Qué hace?**
- Define la estructura exacta de datos que se firma
- Incluye: ID del documento, firmante, rol, hash del contenido y deadline

### **2. Inicialización del Dominio EIP-712** ```solidity
// src/DocumentSignatureManager.sol - Líneas 34-38

function initialize(
    address _institutionDAO,
    address _adminAddress,
    string memory _name,        // "Universidad Nacional Documents"
    string memory _version      // "1"
) external initializer {
    __EIP712_init(_name, _version);  // Configura dominio EIP-712
```

**¿Qué hace?**
- Establece el dominio único para esta institución
- Previene replay attacks entre diferentes instituciones

### **3. Verificación de Firmas EIP-712** ```solidity
// src/DocumentSignatureManager.sol - Líneas 115-135

function _verifySignature(...) internal view returns (bool) {
    // 1. Crear el hash estructurado según EIP-712
    bytes32 structHash = keccak256(abi.encode(
        DOCUMENT_SIGNATURE_TYPEHASH,    // Tipo de estructura
        _documentId,                    // ID del documento
        _signer,                       // Dirección del firmante
        _role,                         // Rol con el que firma
        _documentHash,                 // Hash del contenido
        _deadline                      // Deadline de la firma
    ));

    // 2. Crear el digest final con dominio EIP-712
    bytes32 digest = _hashTypedDataV4(structHash);
    
    // 3. Recuperar la dirección del firmante de la firma
    address recoveredSigner = digest.recover(_signature);
    
    // 4. Verificar que coincide con el firmante esperado
    return recoveredSigner == _signer;
}
```

**Flujo de Verificación:**
1. **Estructura los datos** según el formato EIP-712
2. **Combina con el dominio** de la institución
3. **Recupera la dirección** de la firma criptográfica
4. **Valida** que coincida con el firmante esperado

---

## 📊 **Informe Detallado: Events, Funciones y Elementos del Sistema**

### **🎯 PARA LA INSTITUCIÓN (Administradores)**

#### **1. DocumentFactory.sol**

**Funciones:**
```solidity
// Archivo: src/DocumentFactory.sol

// SETUP INICIAL
function setTemplates(...) external onlyRole(DEFAULT_ADMIN_ROLE) // Línea 48
// Uso: Configurar contratos template una sola vez
// Flujo: Admin del Factory → Configuración global

function deployInstitutionSystem(...) external onlyRole(FACTORY_ADMIN_ROLE) // Línea 60  
// Uso: Desplegar ecosystem completo de una institución
// Flujo: Factory Admin → Nueva institución operativa

// GESTIÓN
function deactivateInstitution(string memory _institutionName) // Línea 185
function reactivateInstitution(string memory _institutionName) // Línea 190
// Uso: Control de estado de instituciones
// Flujo: Factory Admin → Mantenimiento/suspensión

// CONSULTAS
function getInstitutionContracts(string memory _institutionName) // Línea 177
function getAllInstitutions() // Línea 181
// Uso: Obtener direcciones de contratos desplegados
// Flujo: Frontend → Información de instituciones
```

**Events:**
```solidity
event InstitutionDeployed(string indexed institutionName, address indexed deployer); // Línea 35
event ContractsLinked(string indexed institutionName); // Línea 36
event TemplatesSet(address dao, address signature, address nft, address workflow); // Línea 37
// Uso: Tracking de despliegues y configuraciones
// Flujo: Blockchain → Logs para auditabilidad
```

#### **2. InstitutionDAO.sol** **Funciones para Estructura Organizacional:**
```solidity
// Archivo: src/InstitutionDAO.sol

// GESTIÓN DE ROLES
function createRole(string memory _roleName, string memory _description) // Línea 70
// Uso: Crear roles customizados (Registrar, Decano, etc.)
// Flujo: Role Creator → Nuevos roles disponibles

function deactivateRole(bytes32 _roleId) // Línea 105
// Uso: Desactivar roles obsoletos
// Flujo: Admin → Rol inactivo

// GESTIÓN DE MIEMBROS  
function addMember(address _member, string memory _name, string memory _department, bytes32[] memory _roles) // Línea 113
// Uso: Agregar empleados/profesores a la institución
// Flujo: Admin → Miembro activo con roles

function grantMemberRole(address _member, bytes32 _role) // Línea 158
function revokeMemberRole(address _member, bytes32 _role) // Línea 169
// Uso: Gestionar roles dinámicamente
// Flujo: Admin → Cambios de permisos

// GESTIÓN DE DEPARTAMENTOS
function createDepartment(string memory _name, address _head) // Línea 142
// Uso: Crear estructura departamental
// Flujo: Admin → Organización definida
```

**Events:**
```solidity
event MemberAdded(address indexed member, string name, string department); // Línea 44
event MemberRoleGranted(address indexed member, bytes32 indexed role); // Línea 45  
event MemberRoleRevoked(address indexed member, bytes32 indexed role); // Línea 46
event DepartmentCreated(string name, address head); // Línea 47
event RoleCreated(bytes32 indexed roleId, string name, string description, address creator); // Línea 48
event RoleDeactivated(bytes32 indexed roleId); // Línea 49
// Uso: Auditabilidad de cambios organizacionales
// Flujo: Blockchain → Historial de cambios
```

#### **3. DocumentWorkflow.sol** **Funciones para Gestión de Workflows:**
```solidity
// Archivo: src/DocumentWorkflow.sol

// CONFIGURACIÓN DE PLANTILLAS
function createWorkflowTemplate(...) external onlyRole(WORKFLOW_ADMIN_ROLE) // Línea 49
// Uso: Definir flujos de aprobación (Diploma, Certificado, etc.)
// Flujo: Workflow Admin → Plantilla disponible para documentos

// ACTIVACIÓN DE WORKFLOWS
function createDocumentWorkflow(uint256 _documentId, string memory _workflowType) // ~Línea 85
// Uso: Activar flujo específico para un documento
// Flujo: Creator → Documento con workflow activo

// PROCESO DE FIRMAS
function completeWorkflowStep(uint256 _documentId, uint256 _stepIndex, bytes32 _documentHash, bytes memory _signature) // ~Línea 100
// Uso: Avanzar paso del workflow tras firma válida
// Flujo: Firmante → Progreso del workflow
```

**Events:**
```solidity
event WorkflowCreated(uint256 indexed documentId, string workflowType); // Línea 25
event WorkflowStepCompleted(uint256 indexed documentId, uint256 stepIndex, address completedBy); // Línea 26
event WorkflowCompleted(uint256 indexed documentId); // Línea 27
event WorkflowTemplateCreated(string workflowType); // Línea 28
// Uso: Tracking del progreso de firmas
// Flujo: Blockchain → Auditabilidad del proceso
```

#### **4. DocumentNFT.sol** **Funciones para Gestión de Documentos:**
```solidity
// Archivo: src/DocumentNFT.sol

// CREACIÓN DE DOCUMENTOS
function createDocument(...) external onlyRole(MINTER_ROLE) returns (uint256) // ~Línea 48
// Uso: Crear documento NFT para un beneficiario
// Flujo: Authorized Creator → NFT minted al estudiante

// ACTUALIZACIÓN DE ESTADO  
function updateDocumentState(uint256 _tokenId) external onlyRole(UPDATER_ROLE) // Línea 86
// Uso: Actualizar estado basado en firmas completadas
// Flujo: Sistema automático → Estado actualizado

// CONSULTAS
function getDocument(uint256 _tokenId) external view returns (DocumentTypes.Document memory) // ~Línea 150
function getBeneficiary(uint256 _tokenId) external view returns (address) // ~Línea 160
function getDocumentsByBeneficiary(address _beneficiary) external view returns (uint256[] memory) // ~Línea 170
function getDocumentsByState(DocumentTypes.DocumentState _state) external view returns (uint256[] memory) // ~Línea 180
// Uso: Consultar información de documentos
// Flujo: Frontend/Usuario → Información disponible
```

**Events:**
```solidity
event DocumentCreated(uint256 indexed tokenId, string title, address creator, address beneficiary); // Línea 27
event DocumentStateChanged(uint256 indexed tokenId, DocumentTypes.DocumentState newState); // Línea 28
event DocumentMetadataUpdated(uint256 indexed tokenId); // Línea 29
// Uso: Notificaciones de creación y cambios
// Flujo: Blockchain → Notificaciones en tiempo real
```

---

### **🎓 PARA EL USUARIO (Beneficiario/Estudiante)**

#### **1. Funciones de Consulta (Read-Only)**

```solidity
// Ver sus propios documentos
DocumentNFT.getDocumentsByBeneficiary(address _beneficiary) → uint256[] memory
// Archivo: src/DocumentNFT.sol
// Uso: Estudiante ve todos sus certificados
// Flujo: Usuario → Lista de sus NFTs

// Ver detalles de un documento específico  
DocumentNFT.getDocument(uint256 _tokenId) → DocumentTypes.Document memory
// Archivo: src/DocumentNFT.sol
// Uso: Ver información completa del documento
// Flujo: Usuario → Detalles del certificado

// Ver estado del proceso de firmas
DocumentSignatureManager.getDocumentSignatures(uint256 _documentId) → DocumentTypes.DocumentSignature[] memory
// Archivo: src/DocumentSignatureManager.sol
// Uso: Ver progreso de firmas en tiempo real
// Flujo: Usuario → Estado del proceso

// Verificar workflow activo
DocumentWorkflow.getDocumentWorkflow(uint256 _documentId) → DocumentTypes.DocumentWorkflowData memory
// Archivo: src/DocumentWorkflow.sol  
// Uso: Ver pasos completados y pendientes
// Flujo: Usuario → Progreso del workflow
```

#### **2. Funciones Estándar ERC-721**

```solidity
// Transferir documento (si está permitido)
ERC721.transferFrom(address from, address to, uint256 tokenId)
// Archivo: OpenZeppelin ERC721Upgradeable
// Uso: Transferir certificado a otra dirección
// Flujo: Usuario → Nueva propiedad del NFT

// Aprobar transferencia
ERC721.approve(address to, uint256 tokenId)
// Uso: Autorizar a tercero para transferir
// Flujo: Usuario → Autorización de transferencia

// Ver balance de documentos
ERC721.balanceOf(address owner) → uint256
// Uso: Contar certificados totales
// Flujo: Usuario → Cantidad de documentos
```

#### **3. Events Relevantes para el Usuario**

```solidity
// Notificación de documento creado
event DocumentCreated(uint256 indexed tokenId, string title, address creator, address beneficiary);
// Flujo: Sistema → Usuario notificado de nuevo documento

// Cambios de estado del documento
event DocumentStateChanged(uint256 indexed tokenId, DocumentTypes.DocumentState newState);
// Flujo: Sistema → Usuario ve progreso PENDING → ISSUED

// Nueva firma agregada
event SignatureAdded(uint256 indexed documentId, address indexed signer, bytes32 role);
// Flujo: Sistema → Usuario ve cada firma completada

// Workflow completado
event WorkflowCompleted(uint256 indexed documentId);
// Flujo: Sistema → Usuario notificado de completación
```

---

## 🌐 **Flujo Completo con EIP-712**

### **1. Creación de Firma EIP-712 (Frontend)**

```javascript
// Frontend JavaScript/TypeScript
const domain = {
    name: "Universidad Nacional Documents",
    version: "1", 
    chainId: 1,
    verifyingContract: signatureManagerAddress
};

const types = {
    DocumentSignature: [
        { name: "documentId", type: "uint256" },
        { name: "signer", type: "address" },
        { name: "role", type: "bytes32" },
        { name: "documentHash", type: "bytes32" },
        { name: "deadline", type: "uint256" }
    ]
};

const value = {
    documentId: 123,
    signer: "0x742d35Cc6636C0532925a3b8FE71b9617E9F00B7",
    role: "0x1234...", // registrarRole
    documentHash: "0xabcd...",
    deadline: 1692768000
};

// Usuario firma en MetaMask con datos legibles
const signature = await signer._signTypedData(domain, types, value);
```

### **2. Verificación en Smart Contract**

```solidity
// Backend Smart Contract
function _verifySignature(...) internal view returns (bool) {
    // EIP-712 estructura los datos de manera estándar
    bytes32 structHash = keccak256(abi.encode(
        DOCUMENT_SIGNATURE_TYPEHASH,
        _documentId,
        _signer, 
        _role,
        _documentHash,
        _deadline
    ));

    // Combina con dominio de la institución
    bytes32 digest = _hashTypedDataV4(structHash);
    
    // Verifica la firma criptográficamente
    address recoveredSigner = digest.recover(_signature);
    return recoveredSigner == _signer;
}
```

**El EIP-712 asegura que:**
- ✅ Las firmas son **específicas del dominio** (no se pueden reutilizar en otras instituciones)
- ✅ Los datos son **legibles para humanos** (el usuario ve exactamente qué está firmando)
- ✅ La **integridad criptográfica** está garantizada
- ✅ **No hay posibilidad de replay attacks** entre diferentes contratos

Este sistema proporciona un flujo completo, seguro y transparente desde la creación de la institución hasta la emisión de documentos certificados digitalmente.