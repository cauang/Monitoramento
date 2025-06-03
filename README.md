# 📊 Monitoramento de Inatividade do Cursor e Instabilidade de Rede (PowerShell)

Este projeto monitora a inatividade do cursor e a latência da rede em uma máquina Windows (como uma VM). Ele envia **alertas automáticos por e-mail** caso o cursor fique parado por muito tempo ou a conexão com a internet esteja instável.

---

## ✉️ Configuração do E-mail (Gmail)

### 1. Gere uma senha de aplicativo no Gmail

> A senha de aplicativo é **obrigatória** — a senha normal da conta **não funciona** com scripts PowerShell.

1. Acesse: [https://myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
2. Faça login com a conta Gmail desejada.
3. Em **Selecionar app**, escolha **"Outro (personalizado)"**
4. Dê o nome: `powershell-monitor`
5. Clique em **Gerar** e **copie a senha gerada**

> ⚠️ **A verificação em duas etapas deve estar ativada na conta Google para essa opção aparecer.**

---

### 2. Configure os dados no início do script PowerShell

Altere o trecho abaixo com **seu e-mail** e a **senha de app** gerada:

```powershell
$remetente = "seuemail@gmail.com"
$destinatario = "seuemail@gmail.com"
$smtpServer = "smtp.gmail.com"
$smtpPort = 587
$senha = ConvertTo-SecureString "sua_senha_de_app" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($remetente, $senha)
```

### ⚙️ Configuração do Agendador de Tarefas do Windows

#### Como criar a tarefa agendada para execução automática:

1. Abra o **Agendador de Tarefas** (`Win + R` → `taskschd.msc`)
2. Clique em **Criar Tarefa...** (não use “Criar Tarefa Básica”)

---

#### 🗂 Aba Geral

- Nome: `Monitoramento VM`
- Marque: ✅ **Executar com privilégios mais altos**
- Escolha: **Executar esteja o usuário logado ou não**

---

#### 🕒 Aba Disparadores

- Clique em **Novo...**
  - Iniciar a tarefa: `Ao iniciar`
  - *(ou configure para executar diariamente, se preferir)*

---

#### ⚙️ Aba Ações

- Clique em **Novo...**
  - Ação: `Iniciar um programa`
  - **Programa/script**:
    ```bash
    powershell.exe
    ```
  - **Argumentos adicionais**:
    ```bash
    -ExecutionPolicy Bypass -WindowStyle Hidden -File "D:\monitor_cursor.ps1"
    ```
    > Substitua `"D:\monitor_cursor.ps1"` pelo caminho completo do seu script.

---

#### 🔌 Aba Condições

- Desmarque: ❌ **Iniciar a tarefa somente se o computador estiver usando energia elétrica** (se necessário)

---

#### 🛠 Aba Configurações

- Marque:
  - ✅ Permitir que a tarefa seja executada sob demanda
  - ✅ Reiniciar a tarefa se falhar
  - ✅ Parar a tarefa se ela for executada por mais de: *(deixe em branco ou defina um tempo alto)*

---

## 🧪 Teste

- Clique com o botão direito na tarefa criada → **Executar**
- Verifique a **caixa de entrada do seu e-mail** para confirmar se os alertas estão funcionando.

---

## ✅ Recursos do Script

- Envio de e-mails em texto legível (UTF-8) com alertas de:
  - **Inatividade do cursor** (por tempo configurável)
  - **Latência da rede acima do esperado**
- Detecta quando:
  - O **cursor volta a se mover** e avisa por e-mail
  - A **rede se normaliza** e envia notificação

---