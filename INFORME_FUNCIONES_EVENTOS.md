# 📊 Informe Detallado: Events, Funciones y Elementos del Sistema

## 🎯 **PARA LA INSTITUCIÓN (Administradores)**

### **1. DocumentFactory.sol**

#### **Funciones Principales:**

| Función | Línea | Modificador | Uso | Flujo |
|---------|-------|-------------|-----|-------|
| `setTemplates(...)` | 48 | `onlyRole(DEFAULT_ADMIN_ROLE)` | Configurar contratos template una sola vez | Admin del Factory → Configuración global |
| `deployInstitutionSystem(...)` | 60 | `onlyRole(FACTORY_ADMIN_ROLE)` | Desplegar ecosystem completo de una institución | Factory Admin → Nueva institución operativa |
| `deactivateInstitution(string)` | 185 | `onlyRole(FACTORY_ADMIN_ROLE)` | Control de estado de instituciones | Factory Admin → Mantenimiento/suspensión |
| `reactivateInstitution(string)` | 190 | `onlyRole(FACTORY_ADMIN_ROLE)` | Reactivar institución suspendida | Factory Admin → Restaurar operaciones |
| `getInstitutionContracts(string)` | 177 | `view` | Obtener direcciones de contratos desplegados | Frontend → Información de instituciones |
| `getAllInstitutions()` | 181 | `view` | Listar todas las instituciones | Frontend → Lista completa |

#### **Events:**

| Event | Línea | Parámetros | Uso | Flujo |
|-------|-------|------------|-----|-------|
| `InstitutionDeployed` | 35 | `string indexed institutionName, address indexed deployer` | Tracking de despliegues institucionales | Blockchain → Logs para auditabilidad |
| `ContractsLinked` | 36 | `string indexed institutionName` | Confirmación de interconexión de contratos | Blockchain → Validación de setup |
| `TemplatesSet` | 37 | `address dao, address signature, address nft, address workflow` | Registro de configuración de templates | Blockchain → Configuración inicial completada |

---

### **2. InstitutionDAO.sol**

#### **Funciones para Estructura Organizacional:**

| Función | Línea | Modificador | Uso | Flujo |
|---------|-------|-------------|-----|-------|
| `createRole(string, string)` | 70 | `onlyRole(ROLE_CREATOR_ROLE)` | Crear roles customizados (Registrar, Decano, etc.) | Role Creator → Nuevos roles disponibles |
| `deactivateRole(bytes32)` | 105 | `onlyRole(ADMIN_ROLE)` | Desactivar roles obsoletos | Admin → Rol inactivo |
| `addMember(address, string, string, bytes32[])` | 113 | `onlyRole(ADMIN_ROLE)` | Agregar empleados/profesores a la institución | Admin → Miembro activo con roles |
| `grantMemberRole(address, bytes32)` | 158 | `onlyRole(ADMIN_ROLE)` | Gestionar roles dinámicamente | Admin → Cambios de permisos |
| `revokeMemberRole(address, bytes32)` | 169 | `onlyRole(ADMIN_ROLE)` | Revocar roles específicos | Admin → Cambios de permisos |
| `createDepartment(string, address)` | 142 | `onlyRole(ADMIN_ROLE)` | Crear estructura departamental | Admin → Organización definida |

#### **Funciones de Consulta:**

| Función | Línea | Tipo | Uso | Flujo |
|---------|-------|------|-----|-------|
| `getRoleInfo(bytes32)` | 187 | `view` | Obtener información de un rol | Frontend → Detalles del rol |
| `getAllRoles()` | 191 | `view` | Listar todos los roles | Frontend → Lista completa |
| `getActiveRoles()` | 195 | `view` | Obtener solo roles activos | Frontend → Roles utilizables |
| `getMemberRoles(address)` | 217 | `view` | Ver roles de un miembro | Frontend → Permisos del usuario |
| `getDepartmentMembers(string)` | 221 | `view` | Listar miembros de departamento | Frontend → Estructura organizacional |
| `getAllMembers()` | 225 | `view` | Todos los miembros activos | Frontend → Directory completo |
| `getAllDepartments()` | 229 | `view` | Lista de departamentos | Frontend → Estructura organizacional |
| `getRolesByCreator(address)` | 233 | `view` | Roles creados por usuario específico | Frontend → Auditoría de creación |
| `isMember(address)` | 251 | `view` | Verificar si es miembro activo | Otros contratos → Validación de acceso |

#### **Events:**

| Event | Línea | Parámetros | Uso | Flujo |
|-------|-------|------------|-----|-------|
| `MemberAdded` | 44 | `address indexed member, string name, string department` | Notificación de nuevo miembro | Blockchain → Sistema de notificaciones |
| `MemberRoleGranted` | 45 | `address indexed member, bytes32 indexed role` | Tracking de asignación de roles | Blockchain → Auditoría de permisos |
| `MemberRoleRevoked` | 46 | `address indexed member, bytes32 indexed role` | Tracking de revocación de roles | Blockchain → Auditoría de permisos |
| `DepartmentCreated` | 47 | `string name, address head` | Registro de nueva estructura departamental | Blockchain → Cambios organizacionales |
| `RoleCreated` | 48 | `bytes32 indexed roleId, string name, string description, address creator` | Tracking de creación de roles customizados | Blockchain → Auditoría de roles |
| `RoleDeactivated` | 49 | `bytes32 indexed roleId` | Notificación de desactivación de rol | Blockchain → Cambios en estructura de permisos |

---

### **3. DocumentWorkflow.sol**

#### **Funciones para Gestión de Workflows:**

| Función | Línea | Modificador | Uso | Flujo |
|---------|-------|-------------|-----|-------|
| `createWorkflowTemplate(...)` | 49 | `onlyRole(WORKFLOW_ADMIN_ROLE)` | Definir flujos de aprobación (Diploma, Certificado, etc.) | Workflow Admin → Plantilla disponible para documentos |
| `createDocumentWorkflow(uint256, string)` | ~85 | `onlyRole(CREATOR_ROLE)` | Activar flujo específico para un documento | Creator → Documento con workflow activo |
| `completeWorkflowStep(uint256, uint256, bytes32, bytes)` | ~100 | `nonReentrant` | Avanzar paso del workflow tras firma válida | Firmante → Progreso del workflow |

#### **Funciones de Consulta:**

| Función | Línea | Tipo | Uso | Flujo |
|---------|-------|------|-----|-------|
| `getDocumentWorkflow(uint256)` | ~140 | `view` | Ver workflow completo de un documento | Frontend → Estado del proceso |
| `getWorkflowTemplate(string)` | ~145 | `view` | Obtener plantilla de workflow | Frontend → Configuración de proceso |
| `getCurrentStep(uint256)` | ~150 | `view` | Ver paso actual del workflow | Frontend → Progreso en tiempo real |

#### **Events:**

| Event | Línea | Parámetros | Uso | Flujo |
|-------|-------|------------|-----|-------|
| `WorkflowCreated` | 25 | `uint256 indexed documentId, string workflowType` | Notificación de workflow activado | Blockchain → Inicio del proceso |
| `WorkflowStepCompleted` | 26 | `uint256 indexed documentId, uint256 stepIndex, address completedBy` | Tracking del progreso de firmas | Blockchain → Progreso en tiempo real |
| `WorkflowCompleted` | 27 | `uint256 indexed documentId` | Notificación de proceso completado | Blockchain → Documento listo para emisión |
| `WorkflowTemplateCreated` | 28 | `string workflowType` | Registro de nueva plantilla | Blockchain → Nueva configuración disponible |

---

### **4. DocumentNFT.sol**

#### **Funciones para Gestión de Documentos:**

| Función | Línea | Modificador | Uso | Flujo |
|---------|-------|-------------|-----|-------|
| `createDocument(...)` | ~48 | `onlyRole(MINTER_ROLE)` | Crear documento NFT para un beneficiario | Authorized Creator → NFT minted al estudiante |
| `updateDocumentState(uint256)` | 86 | `onlyRole(UPDATER_ROLE)` | Actualizar estado basado en firmas completadas | Sistema automático → Estado actualizado |

#### **Funciones de Consulta:**

| Función | Línea | Tipo | Uso | Flujo |
|---------|-------|------|-----|-------|
| `getDocument(uint256)` | ~150 | `view` | Ver información completa del documento | Frontend/Usuario → Detalles del certificado |
| `getBeneficiary(uint256)` | ~160 | `view` | Obtener beneficiario del documento | Frontend → Propietario del certificado |
| `getDocumentsByBeneficiary(address)` | ~170 | `view` | Listar documentos de un usuario | Frontend → Portfolio personal |
| `getDocumentsByState(DocumentState)` | ~180 | `view` | Filtrar documentos por estado | Frontend → Gestión de estados |

#### **Events:**

| Event | Línea | Parámetros | Uso | Flujo |
|-------|-------|------------|-----|-------|
| `DocumentCreated` | 27 | `uint256 indexed tokenId, string title, address creator, address beneficiary` | Notificación de documento creado | Blockchain → Nuevo documento en el sistema |
| `DocumentStateChanged` | 28 | `uint256 indexed tokenId, DocumentTypes.DocumentState newState` | Tracking de cambios de estado | Blockchain → Progreso del documento |
| `DocumentMetadataUpdated` | 29 | `uint256 indexed tokenId` | Notificación de actualización de metadatos | Blockchain → Cambios en información |

---

### **5. DocumentSignatureManager.sol**

#### **Funciones para Gestión de Firmas:**

| Función | Línea | Modificador | Uso | Flujo |
|---------|-------|-------------|-----|-------|
| `addSignature(uint256, bytes32, bytes32, uint256, bytes)` | ~55 | `nonReentrant` | Agregar firma del usuario actual | Firmante → Firma registrada |
| `addSignatureForSigner(...)` | ~64 | `onlyRole(WORKFLOW_ROLE)` | Agregar firma para usuario específico | Workflow → Firma automática |
| `grantWorkflowRole(address)` | ~46 | `onlyRole(DEFAULT_ADMIN_ROLE)` | Otorgar permisos al workflow | Admin → Configuración de permisos |

#### **Funciones de Consulta:**

| Función | Línea | Tipo | Uso | Flujo |
|---------|-------|------|-----|-------|
| `getDocumentSignatures(uint256)` | 136 | `view` | Ver todas las firmas de un documento | Frontend → Estado del proceso |
| `getSignatureCount(uint256)` | 140 | `view` | Contar firmas completadas | Sistema → Validación de completitud |
| `verifyExternalSignature(...)` | ~144 | `view` | Verificar firma sin almacenar | Frontend → Validación previa |

#### **Events:**

| Event | Línea | Parámetros | Uso | Flujo |
|-------|-------|------------|-----|-------|
| `SignatureAdded` | 30 | `uint256 indexed documentId, address indexed signer, bytes32 role` | Notificación de nueva firma | Blockchain → Progreso en tiempo real |
| `SignatureVerified` | 31 | `uint256 indexed documentId, address indexed signer, bool isValid` | Resultado de verificación de firma | Blockchain → Validación criptográfica |

---

## 🎓 **PARA EL USUARIO (Beneficiario/Estudiante)**

### **1. Funciones de Consulta (Read-Only)**

#### **DocumentNFT.sol - Gestión Personal:**

| Función | Archivo | Uso | Flujo | Ejemplo de Respuesta |
|---------|---------|-----|-------|---------------------|
| `getDocumentsByBeneficiary(address)` | `src/DocumentNFT.sol` | Estudiante ve todos sus certificados | Usuario → Lista de sus NFTs | `[1, 5, 12, 23]` (token IDs) |
| `getDocument(uint256)` | `src/DocumentNFT.sol` | Ver información completa del documento | Usuario → Detalles del certificado | Struct completo con título, estado, etc. |
| `balanceOf(address)` | `OpenZeppelin ERC721` | Contar certificados totales | Usuario → Cantidad de documentos | `4` (número de NFTs) |

#### **DocumentSignatureManager.sol - Estado de Firmas:**

| Función | Archivo | Uso | Flujo | Ejemplo de Respuesta |
|---------|---------|-----|-------|---------------------|
| `getDocumentSignatures(uint256)` | `src/DocumentSignatureManager.sol` | Ver progreso de firmas en tiempo real | Usuario → Estado del proceso | Array de firmas con timestamps |
| `getSignatureCount(uint256)` | `src/DocumentSignatureManager.sol` | Verificar cuántas firmas completadas | Usuario → Progreso numérico | `2` de `3` firmas completadas |

#### **DocumentWorkflow.sol - Progreso del Proceso:**

| Función | Archivo | Uso | Flujo | Ejemplo de Respuesta |
|---------|---------|-----|-------|---------------------|
| `getDocumentWorkflow(uint256)` | `src/DocumentWorkflow.sol` | Ver pasos completados y pendientes | Usuario → Progreso del workflow | Workflow data con pasos |
| `getCurrentStep(uint256)` | `src/DocumentWorkflow.sol` | Ver paso actual que falta | Usuario → Siguiente acción | Datos del paso pendiente |

### **2. Funciones Estándar ERC-721**

#### **Gestión de Propiedad:**

| Función | Origen | Uso | Flujo | Restricciones |
|---------|--------|-----|-------|---------------|
| `transferFrom(address, address, uint256)` | `OpenZeppelin ERC721` | Transferir certificado a otra dirección | Usuario → Nueva propiedad del NFT | Puede estar restringido por la institución |
| `approve(address, uint256)` | `OpenZeppelin ERC721` | Autorizar a tercero para transferir | Usuario → Autorización de transferencia | Solo el propietario puede aprobar |
| `ownerOf(uint256)` | `OpenZeppelin ERC721` | Verificar propietario actual | Cualquiera → Propietario del certificado | Función pública |
| `tokenURI(uint256)` | `OpenZeppelin ERC721` | Obtener metadatos del NFT | Cualquiera → Información del documento | Link a metadatos IPFS |

### **3. Events Relevantes para el Usuario**

#### **Notificaciones de Documentos:**

| Event | Archivo | Parámetros | Cuándo se Emite | Información Proporcionada |
|-------|---------|------------|-----------------|---------------------------|
| `DocumentCreated` | `DocumentNFT.sol` | `uint256 indexed tokenId, string title, address creator, address beneficiary` | Al crear un certificado para el usuario | ID del token, título, quién lo creó |
| `DocumentStateChanged` | `DocumentNFT.sol` | `uint256 indexed tokenId, DocumentTypes.DocumentState newState` | Al cambiar estado del documento | Token ID, nuevo estado (PENDING → ISSUED) |

#### **Progreso de Firmas:**

| Event | Archivo | Parámetros | Cuándo se Emite | Información Proporcionada |
|-------|---------|------------|-----------------|---------------------------|
| `SignatureAdded` | `DocumentSignatureManager.sol` | `uint256 indexed documentId, address indexed signer, bytes32 role` | Cada vez que alguien firma su documento | Documento, quién firmó, con qué rol |
| `WorkflowStepCompleted` | `DocumentWorkflow.sol` | `uint256 indexed documentId, uint256 stepIndex, address completedBy` | Al completar cada paso del workflow | Documento, paso completado, quién lo completó |
| `WorkflowCompleted` | `DocumentWorkflow.sol` | `uint256 indexed documentId` | Todas las firmas están completas | Documento listo para usar |

---

## 🔍 **Flujos de Interacción Específicos**

### **Para Administradores de Institución:**

#### **Flujo 1: Setup Inicial**

| Paso | Función | Contrato | Resultado |
|------|---------|----------|-----------|
| 1 | `Factory.deployInstitutionSystem()` | DocumentFactory | Contratos desplegados |
| 2 | `InstitutionDAO.createDepartment()` | InstitutionDAO | Estructura organizacional |
| 3 | `InstitutionDAO.createRole()` | InstitutionDAO | Roles específicos |
| 4 | `InstitutionDAO.addMember()` | InstitutionDAO | Personal agregado |
| 5 | `DocumentWorkflow.createWorkflowTemplate()` | DocumentWorkflow | Procesos definidos |

#### **Flujo 2: Emisión de Documento**

| Paso | Función | Contrato | Resultado |
|------|---------|----------|-----------|
| 1 | `DocumentNFT.createDocument()` | DocumentNFT | NFT creado |
| 2 | `DocumentWorkflow.createDocumentWorkflow()` | DocumentWorkflow | Proceso activado |
| 3 | `[Esperar firmas]` | Sistema | Proceso en progreso |
| 4 | `DocumentNFT.updateDocumentState()` | DocumentNFT | Estado final |

### **Para Usuarios/Estudiantes:**

#### **Flujo 1: Seguimiento de Progreso**

| Paso | Función | Contrato | Resultado |
|------|---------|----------|-----------|
| 1 | `DocumentNFT.getDocumentsByBeneficiary()` | DocumentNFT | Ver mis documentos |
| 2 | `DocumentNFT.getDocument(tokenId)` | DocumentNFT | Detalles específicos |
| 3 | `DocumentSignatureManager.getDocumentSignatures()` | DocumentSignatureManager | Estado de firmas |
| 4 | `DocumentWorkflow.getCurrentStep()` | DocumentWorkflow | Siguiente paso pendiente |

#### **Flujo 2: Verificación Externa**

| Paso | Función | Contrato | Resultado |
|------|---------|----------|-----------|
| 1 | `ERC721.ownerOf(tokenId)` | DocumentNFT | Verificar propietario |
| 2 | `DocumentNFT.getDocument(tokenId)` | DocumentNFT | Información completa |
| 3 | `DocumentSignatureManager.getDocumentSignatures()` | DocumentSignatureManager | Firmas válidas |
| 4 | `Verificación en blockchain` | Sistema | Autenticidad garantizada |

---

## 📈 **Estados y Transiciones del Sistema**

### **Estados del Sistema:**

| Elemento | Estados Posibles | Descripción | Transiciones |
|----------|------------------|-------------|--------------|
| **Documento** | `PENDING_SIGNATURES` | Esperando firmas | → ISSUED (al completar firmas) |
|  | `ISSUED` | Documento válido y completo | → REVOKED (por admin) |
|  | `REVOKED` | Documento anulado | Estado final |
| **Workflow** | `ACTIVE` | En proceso | → COMPLETED (firmas completas) |
|  | `COMPLETED` | Todas las firmas completadas | → EXPIRED (por tiempo) |
|  | `EXPIRED` | Deadline superado | Estado final |
| **Miembros/Roles** | `active: true` | Miembro/rol activo | ⇄ active: false |
|  | `active: false` | Miembro/rol desactivado | ⇄ active: true |
| **Institución** | `isActive: true` | Institución operativa | ⇄ isActive: false |
|  | `isActive: false` | Institución suspendida | ⇄ isActive: true |

Este informe proporciona una referencia completa de todas las funciones, eventos y elementos disponibles para cada tipo de usuario en el sistema de certificación digital.
