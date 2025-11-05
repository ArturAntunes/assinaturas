# Mini Plataforma de Assinaturas

Sistema de gestão de assinaturas (subscriptions) com cobrança mensal automatizada, desenvolvido em Rails 7.1.

## 📋 Funcionalidades

### Área Admin
- CRUD completo de Planos
- Visualização e gestão de todas as assinaturas
- Visualização de todas as faturas com filtros
- Dashboard com estatísticas

### Área Customer
- Catálogo de planos disponíveis
- Ativar/cancelar assinatura (máximo 1 ativa por vez)
- Visualizar e pagar faturas
- Dashboard personalizado

### API REST (v1)
- Listagem de planos ativos
- Ativação de assinatura
- Consulta de assinatura atual
- Cancelamento de assinatura
- Listagem de faturas
- Detalhes de fatura
- Pagamento de faturas

## 🚀 Requisitos

- Ruby 3.3.4
- Rails 7.1.6
- PostgreSQL
- Node.js (para assets)

## 💻 Setup do Projeto

### 1. Clone o repositório
```bash
git clone <repo-url>
cd assinaturas
```

### 2. Instale as dependências
```bash
bundle install
```

### 3. Configure o banco de dados
```bash
# Ajuste as credenciais em config/database.yml se necessário
rails db:create
rails db:migrate
rails db:seed
```

### 4. Execute o servidor
```bash
rails server
```

Acesse: http://localhost:3000

## 👤 Credenciais de Acesso

### Área Web
- **Admin:** admin@exemplo.com / senha123
- **Customer 1:** joao@exemplo.com / senha123  
- **Customer 2:** maria@exemplo.com / senha123

### Tokens API
Os tokens são gerados automaticamente no seed e exibidos no terminal após executar `rails db:seed`.

## 🔧 Estrutura do Sistema

### Modelos Principais

#### User
- Roles: admin, customer
- Autenticação: has_secure_password (bcrypt)
- Relacionamento: has_many subscriptions

#### Plan
- Periodicidade: monthly, quarterly
- Preço em centavos (price_cents)
- Status: active/inactive

#### Subscription  
- Status: pending, active, canceled
- Regra: apenas 1 assinatura ativa por usuário
- Gera fatura automaticamente ao ativar

#### Invoice
- Status: open, paid, expired
- Referência mensal (reference_month)
- Vencimento em 5 dias após geração

### Services (Regras de Negócio)

- `Subscriptions::ActivateService` - Ativa assinatura e gera primeira fatura
- `Subscriptions::CancelService` - Cancela assinatura ativa
- `Invoices::GenerateService` - Gera fatura mensal

### Jobs

- `GenerateMonthlyInvoicesJob` - Gera faturas mensais para assinaturas ativas
- `ExpireOverdueInvoicesJob` - Marca faturas vencidas como expiradas

## 🧪 Testes

```bash
# Executar todos os testes
rspec

# Executar teste específico
rspec spec/models/user_spec.rb

# Com coverage
COVERAGE=true rspec
```

### Cobertura de Testes
- ✅ Modelos (User, Plan, Subscription, Invoice)
- ✅ Services (ActivateService)
- ✅ API Requests (Plans, Subscriptions)
- ✅ Validações e regras de negócio

## 📝 API Documentation

### Autenticação
Todas as rotas (exceto GET /plans) requerem token no header:
```
Authorization: Bearer <api_token>
```

### Endpoints

#### GET /api/v1/plans
Lista todos os planos ativos
```json
[
  {
    "id": 1,
    "name": "Básico",
    "periodicity": "monthly",
    "price_cents": 2990,
    "formatted_price": "R$ 29,90"
  }
]
```

#### POST /api/v1/subscriptions
Ativa assinatura para o usuário autenticado
```json
// Request
{ "plan_id": 1 }

// Response
{
  "message": "Assinatura ativada com sucesso",
  "subscription": {
    "id": 1,
    "status": "active",
    "started_at": "2025-11-05T10:00:00Z",
    "plan": { ... }
  }
}
```

#### GET /api/v1/subscriptions/me
Retorna assinatura atual e últimas faturas
```json
{
  "subscription": {
    "id": 1,
    "status": "active",
    "started_at": "2025-10-01T10:00:00Z",
    "plan": { ... }
  },
  "recent_invoices": [ ... ]
}
```

#### DELETE /api/v1/subscriptions/cancel
Cancela a assinatura ativa do usuário
```json
{
  "message": "Assinatura cancelada com sucesso",
  "subscription": {
    "id": 1,
    "status": "canceled",
    "started_at": "2025-10-01T10:00:00Z"
  }
}
```

#### GET /api/v1/invoices
Lista todas as faturas do usuário
```json
[
  {
    "id": 1,
    "reference_month": "2025-11-01",
    "amount_cents": 2990,
    "formatted_amount": "R$ 29,90",
    "due_on": "2025-11-06",
    "status": "open",
    "paid_at": null,
    "can_be_paid": true,
    "subscription": {
      "id": 1,
      "status": "active",
      "plan_name": "Básico"
    }
  }
]
```

#### GET /api/v1/invoices/:id
Retorna detalhes de uma fatura específica
```json
{
  "id": 1,
  "reference_month": "2025-11-01",
  "amount_cents": 2990,
  "formatted_amount": "R$ 29,90",
  "due_on": "2025-11-06",
  "status": "open",
  "paid_at": null,
  "can_be_paid": true,
  "subscription": { ... }
}
```

#### POST /api/v1/invoices/:id/pay
Marca fatura como paga (apenas se assinatura ativa)
```json
{
  "message": "Pagamento registrado com sucesso",
  "invoice": {
    "id": 1,
    "status": "paid",
    "paid_at": "2025-11-05T10:00:00Z"
  }
}
```

## 🔄 Rotinas Agendadas (Rake Tasks)

```bash
# Gerar faturas mensais (executar no 1º dia do mês)
rails subscriptions:generate_monthly_invoices

# Marcar faturas vencidas como expiradas
rails subscriptions:expire_overdue_invoices

# Executar rotina mensal completa
rails subscriptions:monthly_routine
```

Para produção, configure um cron job ou use whenever/sidekiq-cron.

## 🏗️ Decisões Arquiteturais

### Por que Services?
- **Separação de responsabilidades:** Controllers magros, lógica isolada
- **Testabilidade:** Facilita testes unitários
- **Reutilização:** Mesma lógica usada em web e API
- **Transações:** Garante atomicidade em operações complexas

### Por que Enums?
- **Performance:** Armazenamento eficiente no banco
- **Validação:** Rails valida automaticamente
- **Queries:** Facilita filtros e scopes
- **Legibilidade:** Código mais expressivo

### Organização de Controllers
- **Namespaces:** Separação clara entre Admin/Customer/API
- **BaseControllers:** Centraliza autenticação e autorização
- **RESTful:** Segue convenções Rails

### Modelagem de Preços
- **price_cents:** Evita problemas de ponto flutuante
- **formatted_price:** Helper para exibição consistente

## 📚 Melhorias Futuras (Bônus Implementados)

- ✅ Paginação com Kaminari
- ✅ Filtros nas listagens
- ✅ Jobs para rotinas automatizadas
- ✅ API completa com autenticação
- ⬜ Docker/Docker Compose
- ⬜ CI/CD com GitHub Actions
- ⬜ Webhook para confirmação de pagamento
- ⬜ Sidekiq para jobs assíncronos

## 🤝 Como Contribuir

1. Fork o projeto
2. Crie uma feature branch (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Add: MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## 📌 Observações Importantes

- Sistema usa `has_secure_password` para autenticação simples
- Faturas são geradas com vencimento em 5 dias
- Apenas 1 assinatura ativa permitida por usuário
- Jobs executam com adapter inline (development)
- Sem integração real com gateway de pagamento
