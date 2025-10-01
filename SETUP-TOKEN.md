# TOKEN: Setup do Personal Access Token

Para que os workflows funcionem e criem PRs automaticamente, você precisa configurar um Personal Access Token.

## 1. Criar Personal Access Token

1. Acesse: https://github.com/settings/tokens
2. Clique em **"Generate new token"** → **"Generate new token (classic)"**
3. Configure:
   - **Note**: `GitHub Actions - Auto PR Creation`
   - **Expiration**: `90 days` (ou o que preferir)
   - **Scopes** (selecione):
     - REQUIRED: `repo` (Full control of private repositories)
     - REQUIRED: `workflow` (Update GitHub Action workflows)

4. Clique em **"Generate token"**
5. **COPIE O TOKEN** (você não verá novamente!)

## 2. Adicionar como Secret no Repositório

1. Acesse: https://github.com/iesodias/k8s-gh/settings/secrets/actions
2. Clique em **"New repository secret"**
3. Configure:
   - **Name**: `TOKEN_GB`
   - **Secret**: cole o token copiado
4. Clique em **"Add secret"**

## 3. Testar o Fluxo

Após configurar o secret:

1. Faça um novo push na branch `feature/teste-workflow`
2. O workflow `00-feature.yml` deve executar sem erros
3. Deve criar automaticamente um PR para `develop`

## 4. Verificar

- **Actions**: https://github.com/iesodias/k8s-gh/actions
- **Pull Requests**: https://github.com/iesodias/k8s-gh/pulls

---

WARNING: **IMPORTANTE**: Mantenha o token seguro e nunca o exponha em código!