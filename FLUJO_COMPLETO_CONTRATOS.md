# 🚀 Flujo Completo de Funcionamiento: BuildatonCertified

## 📋 **Resumen del Flujo**

Este documento detalla paso a paso cómo funciona el sistema **BuildatonCertified** desde el despliegue inicial hasta la emisión de un documento certificado completo. Incluye fragmentos de código, referencias a archivos y explicaciones técnicas detalladas.

---

## 🎯 **FASE 0: Preparación del Entorno**

### **0.1 Configuración del Proyecto**

```bash
# Clonar y configurar proyecto
git clone https://github.com/r33anz/buildatonCertified.git
cd buildatonCertified

# Instalar dependencias
forge install

# Configurar variables de entorno
export SEPOLIA_RPC_URL="https://sepolia.infura.io/v3/YOUR_KEY"
export PRIVATE_KEY="your_private_key"
export ETHERSCAN_API_KEY="your_etherscan_key"
```

### **0.2 Verificar Configuración**

```toml
# foundry.toml - Líneas 1-15
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
optimizer = true
optimizer_runs = 200
via_ir = true
gas_limit = 30000000

remappings = [
    "@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/",
    "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/"
]
```

---

## 🏗️ **FASE 1: Despliegue de Templates y Factory**

### **1.1 Ejecución del Script de Despliegue**

```bash
# Ejecutar script de despliegue en Sepolia
forge script script/DeployFactory.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

### **1.2 Análisis del Script DeployFactory.s.sol**

```solidity
// script/DeployFactory.s.sol - Líneas 1-20
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {DocumentFactory} from "../src/DocumentFactory.sol";
import {InstitutionDAO} from "../src/InstitutionDAO.sol";
import {DocumentSignatureManager} from "../src/DocumentSignatureManager.sol";
import {DocumentNFT} from "../src/DocumentNFT.sol";
import {DocumentWorkflow} from "../src/DocumentWorkflow.sol";

contract DeployFactory is Script {
    function run() external {
        vm.startBroadcast();
        
        // 1. DESPLEGAR TEMPLATES (implementaciones base)
        address institutionDAOTemplate = address(new InstitutionDAO());
        address signatureManagerTemplate = address(new DocumentSignatureManager());
        address documentNFTTemplate = address(new DocumentNFT());
        address documentWorkflowTemplate = address(new DocumentWorkflow());
```

**¿Qué sucede aquí?**
1. **Templates se despliegan primero**: Estos son los contratos "molde" que se usarán para crear clones
2. **Cada template es una implementación completa**: Contienen toda la lógica pero no se inicializan
3. **Eficiencia de gas**: Los clones posteriores solo costarán ~2,000 gas vs ~2,000,000 del despliegue completo

### **1.3 Despliegue del Factory**

```solidity
// script/DeployFactory.s.sol - Líneas 25-35
        // 2. DESPLEGAR FACTORY
        address factory = address(new DocumentFactory());
        
        // 3. INICIALIZAR FACTORY
        DocumentFactory(factory).initialize();
        
        // 4. CONFIGURAR TEMPLATES EN FACTORY
        DocumentFactory(factory).setTemplates(
            institutionDAOTemplate,
            signatureManagerTemplate,
            documentNFTTemplate,
            documentWorkflowTemplate
        );
```

**Proceso detallado:**

#### **A) Inicialización del Factory**
```solidity
// src/DocumentFactory.sol - Líneas 42-47
function initialize() external initializer {
    __AccessControl_init();
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(FACTORY_ADMIN_ROLE, msg.sender);
}
```

**¿Qué hace?**
- `__AccessControl_init()`: Inicializa sistema de roles de OpenZeppelin
- `_grantRole(DEFAULT_ADMIN_ROLE, msg.sender)`: El deployer obtiene control total
- `_grantRole(FACTORY_ADMIN_ROLE, msg.sender)`: Puede crear instituciones

#### **B) Configuración de Templates**
```solidity
// src/DocumentFactory.sol - Líneas 49-60
function setTemplates(
    address _institutionDAOTemplate,
    address _signatureManagerTemplate,
    address _documentNFTTemplate,
    address _documentWorkflowTemplate
) external onlyRole(DEFAULT_ADMIN_ROLE) {
    institutionDAOTemplate = _institutionDAOTemplate;
    signatureManagerTemplate = _signatureManagerTemplate;
    documentNFTTemplate = _documentNFTTemplate;
    documentWorkflowTemplate = _documentWorkflowTemplate;
    
    emit TemplatesSet(_institutionDAOTemplate, _signatureManagerTemplate, _documentNFTTemplate, _documentWorkflowTemplate);
}
```

**Resultado**: Factory queda configurado con direcciones de templates listos para cloning.

### **1.4 Almacenamiento de Direcciones**

```solidity
// script/DeployFactory.s.sol - Líneas 40-55
        // 5. GENERAR ARCHIVO DE CONFIGURACIÓN
        string memory json = string(abi.encodePacked(
            '{\n',
            '  "factory": "', vm.toString(factory), '",\n',
            '  "institutionDAOTemplate": "', vm.toString(institutionDAOTemplate), '",\n',
            '  "signatureManagerTemplate": "', vm.toString(signatureManagerTemplate), '",\n',
            '  "documentNFTTemplate": "', vm.toString(documentNFTTemplate), '",\n',
            '  "documentWorkflowTemplate": "', vm.toString(documentWorkflowTemplate), '"\n',
            '}'
        ));
        
        vm.writeFile("deployed-contracts.json", json);
```

**Resultado**: Archivo `deployed-contracts.json` con todas las direcciones para uso posterior.

---

## 🏛️ **FASE 2: Despliegue de Institución**

### **2.1 Script de Despliegue Institucional**

```bash
# Desplegar institución específica
forge script script/DeployInstitution.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

### **2.2 Carga de Configuración Existente**

```solidity
// script/DeployInstitution.s.sol - Líneas 15-25
contract DeployInstitution is Script {
    function run() external {
        // 1. CARGAR CONFIGURACIÓN EXISTENTE
        string memory json = vm.readFile("deployed-contracts.json");
        address factoryAddress = vm.parseJsonAddress(json, ".factory");
        
        vm.startBroadcast();
        
        DocumentFactory factory = DocumentFactory(factoryAddress);
        
        // 2. DESPLEGAR SISTEMA INSTITUCIONAL COMPLETO
        DocumentFactory.DeployedContracts memory contracts = factory.deployInstitutionSystem(
```

### **2.3 Llamada a deployInstitutionSystem()**

```solidity
// script/DeployInstitution.s.sol - Líneas 30-35
        DocumentFactory.DeployedContracts memory contracts = factory.deployInstitutionSystem(
            "Universidad Nacional",           // Nombre de la institución
            "UNA Academic Documents",         // Nombre de la colección NFT
            "UNADOC",                        // Símbolo NFT
            msg.sender                       // Admin de la institución
        );
```

### **2.4 Análisis Detallado de deployInstitutionSystem()**

#### **A) Validaciones Iniciales**
```solidity
// src/DocumentFactory.sol - Líneas 65-75
function deployInstitutionSystem(
    string memory _institutionName,
    string memory _nftName,
    string memory _nftSymbol,
    address _adminAddress
) external onlyRole(FACTORY_ADMIN_ROLE) returns (DeployedContracts memory) {
    require(institutionContracts[_institutionName].institutionDAO == address(0), "Institution already deployed");
    require(_templatesSet(), "Templates not set");
```

**Validaciones:**
1. **Solo Factory Admin**: `onlyRole(FACTORY_ADMIN_ROLE)` verifica permisos
2. **No duplicación**: Verifica que la institución no exista
3. **Templates configurados**: `_templatesSet()` valida que todos los templates estén listos

#### **B) Cloning del InstitutionDAO**
```solidity
// src/DocumentFactory.sol - Líneas 77-79
        // 1. Clone InstitutionDAO
        address institutionDAO = _cloneContract(institutionDAOTemplate, _institutionName, "DAO");
        IInstitutionDAO(institutionDAO).initialize(_adminAddress);
```

**Proceso de Cloning:**
```solidity
// src/DocumentFactory.sol - Líneas 153-171
function _cloneContract(address template, string memory institutionName, string memory contractType) internal returns (address) {
    bytes32 salt = keccak256(abi.encodePacked(institutionName, contractType, block.timestamp));
    
    // Minimal proxy pattern (EIP-1167)
    bytes memory bytecode = abi.encodePacked(
        hex"3d602d80600a3d3981f3363d3d373d3d3d363d73",
        template,
        hex"5af43d82803e903d91602b57fd5bf3"
    );
    
    address clone;
    assembly {
        clone := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
    }
    
    require(clone != address(0), "Clone deployment failed");
    return clone;
}
```

**¿Qué es EIP-1167?**
- **Minimal Proxy**: Solo 45 bytes de bytecode que delega todo al template
- **CREATE2**: Dirección determinística usando salt único
- **Gas eficiente**: ~2,000 gas vs ~2,000,000 del contrato completo

**Inicialización del DAO:**
```solidity
// src/InstitutionDAO.sol - Líneas 57-68
function initialize(address _admin) external initializer {
    __AccessControl_init();
    
    _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    _grantRole(ADMIN_ROLE, _admin);
    _grantRole(ROLE_CREATOR_ROLE, _admin);

    _setRoleAdmin(ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
    _setRoleAdmin(ROLE_CREATOR_ROLE, ADMIN_ROLE);
    
    _createSystemRole(ADMIN_ROLE, "Administrator", "System administrator with full access");
    _createSystemRole(ROLE_CREATOR_ROLE, "Role Creator", "Can create and manage custom roles");
}
```

#### **C) Cloning del DocumentSignatureManager**
```solidity
// src/DocumentFactory.sol - Líneas 81-89
        // 2. Clone DocumentSignatureManager
        address signatureManager = _cloneContract(signatureManagerTemplate, _institutionName, "SIG");
        IDocumentSignatureManager sigManager = IDocumentSignatureManager(signatureManager);
        sigManager.initialize(
            institutionDAO,
            address(this),
            string(abi.encodePacked(_institutionName, " Documents")),
            "1"
        );
        sigManager.grantRole(sigManager.DEFAULT_ADMIN_ROLE(), _adminAddress);
```

**Inicialización del SignatureManager:**
```solidity
// src/DocumentSignatureManager.sol - Líneas 34-43
function initialize(
    address _institutionDAO,
    address _adminAddress,
    string memory _name,
    string memory _version
) external initializer {
    __EIP712_init(_name, _version);
    __AccessControl_init();
    
    institutionDAO = InstitutionDAO(_institutionDAO);
    _grantRole(DEFAULT_ADMIN_ROLE, _adminAddress);
    _grantRole(MANAGER_ROLE, _adminAddress);
}
```

**Configuración EIP-712:**
- `_name`: "Universidad Nacional Documents" (dominio único)
- `_version`: "1" (versión del protocolo)
- **Dominio único**: Previene replay attacks entre instituciones

#### **D) Cloning del DocumentNFT**
```solidity
// src/DocumentFactory.sol - Líneas 91-95
        // 3. Clone DocumentNFT
        address documentNFT = _cloneContract(documentNFTTemplate, _institutionName, "NFT");
        IDocumentNFT nft = IDocumentNFT(documentNFT);
        nft.initialize(_nftName, _nftSymbol, address(this), signatureManager, institutionDAO);
        nft.grantRole(nft.DEFAULT_ADMIN_ROLE(), _adminAddress);
```

**Inicialización del NFT:**
```solidity
// src/DocumentNFT.sol - Líneas 31-43
function initialize(
    string memory _name,
    string memory _symbol,
    address _adminAddress,
    address _signatureManager,
    address _institutionDAO
) external initializer {
    __ERC721_init(_name, _symbol);
    __AccessControl_init();
    __ReentrancyGuard_init();
    
    signatureManager = DocumentSignatureManager(_signatureManager);
    institutionDAO = InstitutionDAO(_institutionDAO);
    
    _grantRole(DEFAULT_ADMIN_ROLE, _adminAddress);
    _grantRole(MINTER_ROLE, _adminAddress);
    _grantRole(UPDATER_ROLE, _adminAddress);
}
```

#### **E) Cloning del DocumentWorkflow**
```solidity
// src/DocumentFactory.sol - Líneas 97-101
        // 4. Clone DocumentWorkflow
        address documentWorkflow = _cloneContract(documentWorkflowTemplate, _institutionName, "WF");
        IDocumentWorkflow workflow = IDocumentWorkflow(documentWorkflow);
        workflow.initialize(address(this), documentNFT, signatureManager, institutionDAO);
        workflow.grantRole(workflow.DEFAULT_ADMIN_ROLE(), _adminAddress);
```

#### **F) Configuración de Interconexiones**
```solidity
// src/DocumentFactory.sol - Líneas 103-106
        // 5. Grant workflow role
        sigManager.grantWorkflowRole(documentWorkflow);

        // 6. Setup permissions
        _setupPermissions(nft, sigManager, workflow, _adminAddress);
```

**Configuración de Permisos Cruzados:**
```solidity
// src/DocumentFactory.sol - Líneas 139-151
function _setupPermissions(
    IDocumentNFT _nft,
    IDocumentSignatureManager _sigManager,
    IDocumentWorkflow _workflow,
    address _admin
) internal {
    // Grant roles to workflow and signature manager
    _nft.grantRole(_nft.UPDATER_ROLE(), address(_workflow));
    _nft.grantRole(_nft.UPDATER_ROLE(), address(_sigManager));
    _nft.grantRole(_nft.MINTER_ROLE(), address(_workflow));
    _nft.grantRole(_nft.MINTER_ROLE(), _admin);

    _sigManager.grantRole(_sigManager.MANAGER_ROLE(), address(_workflow));
    _sigManager.grantRole(_sigManager.MANAGER_ROLE(), _admin);

    _workflow.grantRole(_workflow.CREATOR_ROLE(), _admin);
    _workflow.grantRole(_workflow.WORKFLOW_ADMIN_ROLE(), _admin);
}
```

**Matriz de Permisos Resultante:**
| Contrato | Rol | Workflow | SignatureManager | Admin |
|----------|-----|----------|------------------|-------|
| NFT | UPDATER_ROLE | ✅ | ✅ | ❌ |
| NFT | MINTER_ROLE | ✅ | ❌ | ✅ |
| SignatureManager | MANAGER_ROLE | ✅ | ❌ | ✅ |
| Workflow | CREATOR_ROLE | ❌ | ❌ | ✅ |

#### **G) Revocación de Roles Temporales**
```solidity
// src/DocumentFactory.sol - Líneas 108-111
        // 7. Renounce factory admin roles
        sigManager.renounceRole(sigManager.DEFAULT_ADMIN_ROLE(), address(this));
        nft.renounceRole(nft.DEFAULT_ADMIN_ROLE(), address(this));
        workflow.renounceRole(workflow.DEFAULT_ADMIN_ROLE(), address(this));
```

**¿Por qué renunciar?**
- **Descentralización**: Factory no mantiene control sobre instituciones
- **Seguridad**: Cada institución es autónoma
- **Irreversible**: Una vez renunciado, no se puede reconfigurar

#### **H) Almacenamiento y Confirmación**
```solidity
// src/DocumentFactory.sol - Líneas 113-127
        // 8. Store contracts
        DeployedContracts memory contracts = DeployedContracts({
            institutionDAO: institutionDAO,
            signatureManager: signatureManager,
            documentNFT: documentNFT,
            documentWorkflow: documentWorkflow,
            deployedAt: block.timestamp,
            isActive: true
        });

        institutionContracts[_institutionName] = contracts;
        allInstitutions.push(_institutionName);

        emit InstitutionDeployed(_institutionName, msg.sender);
        emit ContractsLinked(_institutionName);

        return contracts;
```

---

## 👥 **FASE 3: Configuración Organizacional**

### **3.1 Obtener Direcciones de Contratos**

```solidity
// Desde el script o frontend
DocumentFactory.DeployedContracts memory uni = factory.getInstitutionContracts("Universidad Nacional");
IInstitutionDAO dao = IInstitutionDAO(uni.institutionDAO);
```

### **3.2 Crear Roles Específicos**

```solidity
// Ejemplo de configuración organizacional
contract SetupMembers is Script {
    function run() external {
        // Cargar configuración
        string memory json = vm.readFile("deployed-contracts.json");
        address daoAddress = vm.parseJsonAddress(json, ".universidadNacional.institutionDAO");
        
        vm.startBroadcast();
        
        IInstitutionDAO dao = IInstitutionDAO(daoAddress);
        
        // Crear roles específicos de la universidad
        bytes32 registrarRole = dao.createRole(
            "Academic Registrar",
            "Responsible for validating academic records and degrees"
        );
        
        bytes32 deanRole = dao.createRole(
            "Dean",
            "Faculty dean with authority to approve degrees"
        );
        
        bytes32 professorRole = dao.createRole(
            "Professor",
            "Teaching faculty member who can validate course completion"
        );
```

**Análisis de createRole():**
```solidity
// src/InstitutionDAO.sol - Líneas 70-90
function createRole(
    string memory _roleName,
    string memory _description
) external onlyRole(ROLE_CREATOR_ROLE) returns (bytes32) {
    bytes32 roleId = keccak256(abi.encodePacked(_roleName, block.timestamp, msg.sender));
    
    require(!roleInfos[roleId].active, "Role ID collision");
    require(bytes(_roleName).length > 0, "Role name cannot be empty");

    roleInfos[roleId] = RoleInfo({
        name: _roleName,
        description: _description,
        active: true,
        createdAt: block.timestamp,
        createdBy: msg.sender
    });

    allRoles.push(roleId);
    _setRoleAdmin(roleId, ADMIN_ROLE);

    emit RoleCreated(roleId, _roleName, _description, msg.sender);
    return roleId;
}
```

**Características del Sistema de Roles:**
- **ID único**: Combinación de nombre, timestamp y creador
- **Metadata rica**: Nombre, descripción, fecha de creación
- **Administración**: Rol ADMIN_ROLE puede asignar/revocar
- **Auditabilidad**: Event logging completo

### **3.3 Crear Departamentos**

```solidity
        // Crear estructura departamental
        dao.createDepartment("Academic Registry", registrarAddress);
        dao.createDepartment("Engineering Faculty", deanAddress);
        dao.createDepartment("Computer Science", professorAddress);
```

**Implementación de createDepartment():**
```solidity
// src/InstitutionDAO.sol - Líneas 142-155
function createDepartment(
    string memory _name,
    address _head
) external onlyRole(ADMIN_ROLE) {
    require(!departments[_name].active, "Department exists");
    
    departments[_name] = Department({
        name: _name,
        head: _head,
        active: true,
        members: new address[](0)
    });
    
    allDepartments.push(_name);
    emit DepartmentCreated(_name, _head);
}
```

### **3.4 Agregar Miembros con Roles**

```solidity
        // Agregar miembros del staff
        bytes32[] memory registrarRoles = new bytes32[](1);
        registrarRoles[0] = registrarRole;
        
        dao.addMember(
            registrarAddress,
            "Maria Rodriguez",
            "Academic Registry",
            registrarRoles
        );
        
        bytes32[] memory deanRoles = new bytes32[](1);
        deanRoles[0] = deanRole;
        
        dao.addMember(
            deanAddress,
            "Dr. Carlos Martinez",
            "Engineering Faculty",
            deanRoles
        );
```

**Análisis de addMember():**
```solidity
// src/InstitutionDAO.sol - Líneas 113-139
function addMember(
    address _member,
    string memory _name,
    string memory _department,
    bytes32[] memory _roles
) external onlyRole(ADMIN_ROLE) {
    require(!members[_member].active, "Member already exists");
    
    for (uint i = 0; i < _roles.length; i++) {
        require(roleInfos[_roles[i]].active, "One or more roles are inactive");
    }
    
    members[_member] = Member({
        active: true,
        joinDate: block.timestamp,
        department: _department,
        name: _name,
        assignedRoles: _roles
    });

    for (uint i = 0; i < _roles.length; i++) {
        _grantRole(_roles[i], _member);
    }

    allMembers.push(_member);
    departments[_department].members.push(_member);
    
    emit MemberAdded(_member, _name, _department);
}
```

**Validaciones Importantes:**
1. **No duplicación**: Verifica que el miembro no exista
2. **Roles válidos**: Todos los roles deben estar activos
3. **Doble registro**: Tanto en OpenZeppelin como en mapping local
4. **Estructura departamental**: Agrega al departamento correspondiente

---

## 🔄 **FASE 4: Configuración de Workflows**

### **4.1 Crear Template de Workflow**

```solidity
// Configurar workflow para diplomas de graduación
contract SetupWorkflows is Script {
    function run() external {
        // Cargar direcciones
        string memory json = vm.readFile("deployed-contracts.json");
        address workflowAddress = vm.parseJsonAddress(json, ".universidadNacional.documentWorkflow");
        
        vm.startBroadcast();
        
        IDocumentWorkflow workflow = IDocumentWorkflow(workflowAddress);
        
        // Definir roles requeridos (deben existir en el DAO)
        bytes32[] memory roles = new bytes32[](3);
        roles[0] = professorRole;    // Paso 1: Profesor valida
        roles[1] = registrarRole;    // Paso 2: Registrar verifica
        roles[2] = deanRole;         // Paso 3: Decano aprueba

        bool[] memory required = new bool[](3);
        required[0] = true;  // Profesor obligatorio
        required[1] = true;  // Registrar obligatorio  
        required[2] = true;  // Decano obligatorio

        uint256[] memory order = new uint256[](3);
        order[0] = 1;  // Profesor firma primero
        order[1] = 2;  // Registrar segundo
        order[2] = 3;  // Decano último

        uint256[] memory deadlines = new uint256[](3);
        deadlines[0] = 7 days;   // Profesor tiene 7 días
        deadlines[1] = 3 days;   // Registrar tiene 3 días después del profesor
        deadlines[2] = 2 days;   // Decano tiene 2 días después del registrar

        workflow.createWorkflowTemplate(
            "GRADUATION_DIPLOMA",
            roles,
            required,
            order,
            deadlines
        );
```

**Implementación de createWorkflowTemplate():**
```solidity
// src/DocumentWorkflow.sol - Líneas 49-77
function createWorkflowTemplate(
    string memory _workflowType,
    bytes32[] memory roles,
    bool[] memory isRequired,
    uint256[] memory order,
    uint256[] memory deadline
) external onlyRole(WORKFLOW_ADMIN_ROLE) {
    require(
        roles.length == isRequired.length &&
        roles.length == order.length &&
        roles.length == deadline.length,
        "Input array length mismatch"
    );

    delete workflowTemplates[_workflowType];

    for (uint i = 0; i < roles.length; i++) {
        DocumentTypes.WorkflowStep memory step = DocumentTypes.WorkflowStep({
            role: roles[i],
            isRequired: isRequired[i],
            order: order[i],
            deadline: deadline[i],
            isCompleted: false,
            completedBy: address(0),
            completedAt: 0
        });

        workflowTemplates[_workflowType].push(step);
    }

    emit WorkflowTemplateCreated(_workflowType);
}
```

**Características del Sistema de Workflows:**
- **Reutilizable**: Un template puede usarse para múltiples documentos
- **Configurable**: Orden, deadlines y obligatoriedad por paso
- **Validación**: Arrays deben tener la misma longitud
- **Limpieza**: `delete` previo evita duplicación

---

## 📄 **FASE 5: Creación de Documento**

### **5.1 Crear Documento NFT**

```solidity
// Crear certificado de graduación para un estudiante
contract CreateDocument is Script {
    function run() external {
        // Cargar configuración
        string memory json = vm.readFile("deployed-contracts.json");
        address nftAddress = vm.parseJsonAddress(json, ".universidadNacional.documentNFT");
        
        vm.startBroadcast();
        
        IDocumentNFT nft = IDocumentNFT(nftAddress);
        
        // Definir roles requeridos para firmar
        bytes32[] memory requiredRoles = new bytes32[](3);
        requiredRoles[0] = professorRole;
        requiredRoles[1] = registrarRole;
        requiredRoles[2] = deanRole;
        
        uint256 tokenId = nft.createDocument(
            studentAddress,                    // beneficiario
            "Bachelor's Degree in Computer Science", // título
            "Graduation certificate for Computer Systems Engineering with honors", // descripción
            "QmX1Y2Z3ABC123...",              // hash IPFS del PDF
            keccak256("document content"),     // hash del contenido para verificación
            block.timestamp + 30 days,        // deadline para completar firmas
            requiredRoles,                    // roles requeridos para firmar
            "GRADUATION_DIPLOMA"              // tipo de documento
        );
```

**Análisis de createDocument():**
```solidity
// src/DocumentNFT.sol - Líneas 48-87
function createDocument(
    address _beneficiary,
    string memory _title,
    string memory _description,
    string memory _ipfsHash,
    bytes32 _documentHash,
    uint256 _deadline,
    bytes32[] memory _requiredRoles,
    string memory _documentType
) external onlyRole(MINTER_ROLE) returns (uint256) {
    _tokenIdCounter++;
    uint256 tokenId = _tokenIdCounter;

    documents[tokenId] = DocumentTypes.Document({
        title: _title,
        description: _description,
        ipfsHash: _ipfsHash,
        documentHash: _documentHash,
        state: DocumentTypes.DocumentState.PENDING_SIGNATURES,
        createdAt: block.timestamp,
        deadline: _deadline,
        creator: msg.sender,
        requiredRoles: _requiredRoles,
        requiredSignatures: _requiredRoles.length,
        documentType: _documentType,
        metadata: ""
    });

    // Guardar el beneficiario
    documentBeneficiary[tokenId] = _beneficiary;

    // Mintear el NFT directamente al beneficiario
    _safeMint(_beneficiary, tokenId);
    _updateMetadata(tokenId);

    emit DocumentCreated(tokenId, _title, msg.sender, _beneficiary);
    emit DocumentStateChanged(tokenId, DocumentTypes.DocumentState.PENDING_SIGNATURES);
    
    return tokenId;
}
```

**Estados del Documento:**
```solidity
// src/libraries/DocumentTypes.sol - Líneas 6-11
enum DocumentState {
    PENDING_SIGNATURES,  // Esperando firmas
    ISSUED,             // Completado y válido
    REVOKED             // Anulado por admin
}
```

**Características del Sistema NFT:**
- **Beneficiario específico**: NFT se mintea directamente al estudiante
- **Metadata onchain**: Se genera dinámicamente en `tokenURI()`
- **Estado inicial**: PENDING_SIGNATURES
- **IPFS integration**: Hash del documento almacenado en blockchain

### **5.2 Activar Workflow para el Documento**

```solidity
        // Activar workflow específico para este documento
        IDocumentWorkflow workflow = IDocumentWorkflow(workflowAddress);
        workflow.createDocumentWorkflow(tokenId, "GRADUATION_DIPLOMA");
```

**Implementación de createDocumentWorkflow():**
```solidity
// src/DocumentWorkflow.sol - Líneas 79-110
function createDocumentWorkflow(
    uint256 _documentId,
    string memory _workflowType
) external onlyRole(CREATOR_ROLE) {
    require(workflowTemplates[_workflowType].length > 0, "Workflow template does not exist");
    require(documentWorkflows[_documentId].steps.length == 0, "Workflow already exists for document");

    DocumentTypes.WorkflowStep[] memory templateSteps = workflowTemplates[_workflowType];
    
    for (uint i = 0; i < templateSteps.length; i++) {
        documentWorkflows[_documentId].steps.push(templateSteps[i]);
    }
    
    documentWorkflows[_documentId].workflowType = _workflowType;
    documentWorkflows[_documentId].isActive = true;
    documentWorkflows[_documentId].currentStep = 0;
    documentWorkflows[_documentId].isCompleted = false;
    documentWorkflows[_documentId].createdAt = block.timestamp;

    emit WorkflowCreated(_documentId, _workflowType);
}
```

**Resultado**: El documento tiene un workflow activo que define el proceso de firmas.

---

## ✍️ **FASE 6: Proceso de Firmas**

### **6.1 Primera Firma: Profesor**

```solidity
// Profesor firma el documento (paso 1)
contract SignDocument is Script {
    function run() external {
        vm.startBroadcast(professorPrivateKey);
        
        // Preparar datos para firma EIP-712
        uint256 documentId = 1;
        bytes32 documentHash = keccak256("document content");
        uint256 deadline = block.timestamp + 7 days;
        
        // Crear firma EIP-712 (normalmente en frontend con MetaMask)
        bytes memory signature = _createEIP712Signature(
            documentId,
            professorRole,
            documentHash,
            deadline,
            professorPrivateKey
        );
        
        // Registrar firma
        IDocumentSignatureManager sigManager = IDocumentSignatureManager(signatureManagerAddress);
        sigManager.addSignature(
            documentId,
            professorRole,
            documentHash,
            deadline,
            signature
        );
        
        // Avanzar workflow
        IDocumentWorkflow workflow = IDocumentWorkflow(workflowAddress);
        workflow.completeWorkflowStep(
            documentId,
            0,              // Índice del paso (Profesor = paso 0)
            documentHash,
            signature
        );
```

### **6.2 Análisis de la Firma EIP-712**

**Creación de Firma (Frontend):**
```javascript
// Frontend JavaScript/TypeScript
const domain = {
    name: "Universidad Nacional Documents",
    version: "1",
    chainId: 11155111, // Sepolia
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
    documentId: 1,
    signer: professorAddress,
    role: professorRole,
    documentHash: "0xabcd...",
    deadline: 1692768000
};

// Usuario firma en MetaMask con datos legibles
const signature = await signer._signTypedData(domain, types, value);
```

### **6.3 Verificación de Firma en Smart Contract**

```solidity
// src/DocumentSignatureManager.sol - Líneas 75-95
function _addSignature(
    uint256 _documentId,
    address _signer,
    bytes32 _role,
    bytes32 _documentHash,
    uint256 _deadline,
    bytes memory _signature
) internal {
    require(block.timestamp <= _deadline, "Signature deadline passed");
    require(!hasSignerSigned[_documentId][_signer], "Already signed");
    require(institutionDAO.hasRole(_role, _signer), "Invalid role for signer");

    bool isValid = _verifySignature(
        _documentId,
        _signer,
        _role,
        _documentHash,
        _deadline,
        _signature
    );
    
    require(isValid, "Invalid signature");
```

**Verificación EIP-712:**
```solidity
// src/DocumentSignatureManager.sol - Líneas 115-135
function _verifySignature(
    uint256 _documentId,
    address _signer,
    bytes32 _role,
    bytes32 _documentHash,
    uint256 _deadline,
    bytes memory _signature
) internal view returns (bool) {
    bytes32 structHash = keccak256(abi.encode(
        DOCUMENT_SIGNATURE_TYPEHASH,
        _documentId,
        _signer,
        _role,
        _documentHash,
        _deadline
    ));

    bytes32 digest = _hashTypedDataV4(structHash);
    address recoveredSigner = digest.recover(_signature);
    
    return recoveredSigner == _signer;
}
```

**Proceso de Verificación:**
1. **Estructura datos**: Según formato EIP-712
2. **Combina con dominio**: Específico de la institución
3. **Recupera dirección**: De la firma criptográfica
4. **Valida coincidencia**: Con el firmante esperado

### **6.4 Avance del Workflow**

```solidity
// src/DocumentWorkflow.sol - Líneas 120-150
function completeWorkflowStep(
    uint256 _documentId,
    uint256 _stepIndex,
    bytes32 _documentHash,
    bytes memory _signature
) external nonReentrant {
    DocumentTypes.DocumentWorkflowData storage workflow = documentWorkflows[_documentId];
    require(workflow.isActive, "Workflow not active");
    require(_stepIndex == workflow.currentStep, "Invalid step");
    require(!workflow.steps[_stepIndex].isCompleted, "Step already completed");

    // Verificar que el firmante tiene el rol requerido
    bytes32 requiredRole = workflow.steps[_stepIndex].role;
    require(institutionDAO.hasRole(requiredRole, msg.sender), "Insufficient role");

    // Registrar firma en SignatureManager
    signatureManager.addSignatureForSigner(
        _documentId,
        msg.sender,
        requiredRole,
        _documentHash,
        block.timestamp + workflow.steps[_stepIndex].deadline,
        _signature
    );

    // Marcar paso como completado
    workflow.steps[_stepIndex].isCompleted = true;
    workflow.steps[_stepIndex].completedBy = msg.sender;
    workflow.steps[_stepIndex].completedAt = block.timestamp;

    emit WorkflowStepCompleted(_documentId, _stepIndex, msg.sender);

    // Avanzar al siguiente paso o completar workflow
    if (_stepIndex == workflow.steps.length - 1) {
        workflow.isCompleted = true;
        workflow.isActive = false;
        emit WorkflowCompleted(_documentId);
        
        // Actualizar estado del documento
        documentNFT.updateDocumentState(_documentId);
    } else {
        workflow.currentStep++;
    }
}
```

### **6.5 Firmas Subsecuentes: Registrar y Decano**

El proceso se repite para cada firmante:

```solidity
// Registrar firma (paso 2)
vm.startBroadcast(registrarPrivateKey);
// ... mismo proceso con registrarRole

// Decano firma (paso 3 - final)  
vm.startBroadcast(deanPrivateKey);
// ... mismo proceso con deanRole
```

### **6.6 Actualización Final del Estado**

```solidity
// src/DocumentNFT.sol - Líneas 86-105
function updateDocumentState(uint256 _tokenId) external onlyRole(UPDATER_ROLE) {
    require(_exists(_tokenId), "Document does not exist");
    
    DocumentTypes.Document storage doc = documents[_tokenId];
    uint256 signaturesReceived = signatureManager.getSignatureCount(_tokenId);
    
    if (signaturesReceived >= doc.requiredSignatures) {
        doc.state = DocumentTypes.DocumentState.ISSUED;
        _updateMetadata(_tokenId);
        emit DocumentStateChanged(_tokenId, DocumentTypes.DocumentState.ISSUED);
    }
}
```

**Resultado Final**: Documento cambia de PENDING_SIGNATURES → ISSUED

---

## 🔍 **FASE 7: Verificación y Consultas**

### **7.1 Consultar Documento Completo**

```solidity
// Verificar estado final del documento
contract VerifyDocument is Script {
    function run() external view {
        IDocumentNFT nft = IDocumentNFT(nftAddress);
        
        // Información completa del documento
        DocumentTypes.Document memory doc = nft.getDocument(1);
        console.log("Estado:", uint(doc.state));  // 1 = ISSUED
        console.log("Tipo:", doc.documentType);   // "GRADUATION_DIPLOMA"
        console.log("Beneficiario:", nft.getBeneficiary(1));
        
        // Verificar todas las firmas
        IDocumentSignatureManager sigManager = IDocumentSignatureManager(signatureManagerAddress);
        DocumentTypes.DocumentSignature[] memory signatures = sigManager.getDocumentSignatures(1);
        console.log("Firmas totales:", signatures.length);  // 3
        
        // Verificar workflow completado
        IDocumentWorkflow workflow = IDocumentWorkflow(workflowAddress);
        DocumentTypes.DocumentWorkflowData memory workflowData = workflow.getDocumentWorkflow(1);
        console.log("Workflow completado:", workflowData.isCompleted);  // true
    }
}
```

### **7.2 Metadata NFT Generada**

```solidity
// src/DocumentNFT.sol - Líneas 200-230
function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    require(_exists(_tokenId), "Token does not exist");
    
    DocumentTypes.Document memory doc = documents[_tokenId];
    uint256 signatureCount = signatureManager.getSignatureCount(_tokenId);
    
    string memory json = string(abi.encodePacked(
        '{"name": "', doc.title, '",',
        '"description": "', doc.description, '",',
        '"document_type": "', doc.documentType, '",',
        '"state": "', _getStateString(doc.state), '",',
        '"signatures_received": ', Strings.toString(signatureCount), ',',
        '"required_signatures": ', Strings.toString(doc.requiredSignatures), ',',
        '"ipfs_hash": "', doc.ipfsHash, '",',
        '"created_at": ', Strings.toString(doc.createdAt), ',',
        '"deadline": ', Strings.toString(doc.deadline),
        '}'
    ));
    
    return string(abi.encodePacked(
        "data:application/json;base64,",
        Base64.encode(bytes(json))
    ));
}
```

**Metadata Resultado:**
```json
{
    "name": "Bachelor's Degree in Computer Science",
    "description": "Graduation certificate for Computer Systems Engineering with honors",
    "document_type": "GRADUATION_DIPLOMA",
    "state": "ISSUED",
    "signatures_received": 3,
    "required_signatures": 3,
    "ipfs_hash": "QmX1Y2Z3ABC123...",
    "created_at": 1692768000,
    "deadline": 1695360000
}
```

---

## 📊 **Resumen del Flujo Completo**

### **Arquitectura Final Desplegada:**

```
Factory (0x123...)
├── Templates
│   ├── InstitutionDAO (0xABC...)
│   ├── SignatureManager (0xDEF...)
│   ├── DocumentNFT (0xGHI...)
│   └── DocumentWorkflow (0xJKL...)
└── Universidad Nacional
    ├── DAO Clone (0x111...)
    ├── SignatureManager Clone (0x222...)
    ├── NFT Clone (0x333...)
    └── Workflow Clone (0x444...)
```

### **Estados del Sistema:**

| Fase | Elemento | Estado | Descripción |
|------|----------|--------|-------------|
| 1 | Factory | Configurado | Templates listos para cloning |
| 2 | Institución | Desplegada | 4 contratos interconectados |
| 3 | Organización | Configurada | Roles, miembros, departamentos |
| 4 | Workflows | Activos | Templates de proceso definidos |
| 5 | Documento | Creado | NFT minteado, workflow iniciado |
| 6 | Firmas | Completadas | 3/3 firmas válidas EIP-712 |
| 7 | Certificado | Emitido | Estado ISSUED, metadata completa |

### **Transacciones Ejecutadas:**

1. **Deploy Templates** (4 tx): ~8,000,000 gas total
2. **Deploy Factory** (1 tx): ~1,500,000 gas
3. **Configure Factory** (1 tx): ~200,000 gas
4. **Deploy Institution** (1 tx): ~500,000 gas (clones)
5. **Setup Organization** (6 tx): ~1,200,000 gas total
6. **Create Workflows** (1 tx): ~300,000 gas
7. **Create Document** (1 tx): ~400,000 gas
8. **Process Signatures** (3 tx): ~600,000 gas total

**Total: ~12,700,000 gas** para sistema completo operativo

### **Optimizaciones Implementadas:**

- ✅ **EIP-1167 Clones**: 90% reducción en gas de despliegue
- ✅ **EIP-712 Signatures**: Prevención de replay attacks
- ✅ **Access Control**: Roles granulares y seguros
- ✅ **Metadata Onchain**: Sin dependencia externa
- ✅ **Non-transferable NFTs**: Preserva autenticidad
- ✅ **Event Logging**: Auditabilidad completa

Este flujo completo demuestra cómo **BuildatonCertified** proporciona una solución robusta, escalable y segura para la certificación digital institucional en blockchain.
