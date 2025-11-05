puts "🧹 Limpando banco de dados..."
Invoice.destroy_all
Subscription.destroy_all
Plan.destroy_all
User.destroy_all

puts "\n👥 Criando usuários..."

admin = User.create!(
  name: "Admin Sistema",
  email: "admin@exemplo.com",
  password: "senha123",
  password_confirmation: "senha123",
  role: :admin
)
puts "  Admin: #{admin.email} / senha123"

customer1 = User.create!(
  name: "João Silva",
  email: "joao@exemplo.com",
  password: "senha123",
  password_confirmation: "senha123",
  role: :customer
)
puts "  Customer 1: #{customer1.email} / senha123"

customer2 = User.create!(
  name: "Maria Santos",
  email: "maria@exemplo.com",
  password: "senha123",
  password_confirmation: "senha123",
  role: :customer
)
puts "  Customer 2: #{customer2.email} / senha123"

customer3 = User.create!(
  name: "Pedro Costa",
  email: "pedro@exemplo.com",
  password: "senha123",
  password_confirmation: "senha123",
  role: :customer
)
puts "  Customer 3: #{customer3.email} / senha123"

customer4 = User.create!(
  name: "Ana Oliveira",
  email: "ana@exemplo.com",
  password: "senha123",
  password_confirmation: "senha123",
  role: :customer
)
puts "  Customer 4: #{customer4.email} / senha123"

puts "\n📋 Criando planos..."

plan_basic = Plan.create!(
  name: "Básico",
  periodicity: :monthly,
  price_cents: 2990, # R$ 29,90
  active: true
)
puts "  Plano Básico: R$ 29,90"

plan_professional = Plan.create!(
  name: "Profissional",
  periodicity: :monthly,
  price_cents: 5990, # R$ 59,90
  active: true
)
puts "  Plano Profissional: R$ 59,90"

plan_enterprise = Plan.create!(
  name: "Empresarial",
  periodicity: :monthly,
  price_cents: 9990, # R$ 99,90
  active: true
)
puts "  Plano Empresarial: R$ 99,90"

puts "\n📝 Criando assinaturas e cenários..."

# CENÁRIO 1: João - Assinatura ativa com faturas em dia
puts "\n1️⃣ João (joao@exemplo.com):"
subscription1 = Subscription.create!(
  user: customer1,
  plan: plan_basic,
  status: :active,
  started_at: 2.months.ago
)
puts "  - Assinatura ATIVA (Plano Básico)"

# Fatura paga do mês passado
Invoice.create!(
  subscription: subscription1,
  reference_month: 1.month.ago.beginning_of_month,
  amount_cents: plan_basic.price_cents,
  due_on: 1.month.ago.beginning_of_month + 5.days,
  status: :paid,
  paid_at: 1.month.ago.beginning_of_month + 3.days
)
puts "  - Fatura PAGA do mês passado"

# Fatura em aberto do mês atual
Invoice.create!(
  subscription: subscription1,
  reference_month: Date.current.beginning_of_month,
  amount_cents: plan_basic.price_cents,
  due_on: Date.current + 5.days,
  status: :open
)
puts "  - Fatura EM ABERTO do mês atual (vence em 5 dias)"

# CENÁRIO 2: Maria - Assinatura cancelada com fatura expirada
puts "\n2️⃣ Maria (maria@exemplo.com):"
subscription2 = Subscription.create!(
  user: customer2,
  plan: plan_professional,
  status: :canceled,
  started_at: 3.months.ago,
  canceled_at: 1.month.ago
)
puts "  - Assinatura CANCELADA há 1 mês (era Profissional)"

# Fatura paga antiga
Invoice.create!(
  subscription: subscription2,
  reference_month: 2.months.ago.beginning_of_month,
  amount_cents: plan_professional.price_cents,
  due_on: 2.months.ago.beginning_of_month + 5.days,
  status: :paid,
  paid_at: 2.months.ago.beginning_of_month + 2.days
)
puts "  - Fatura PAGA de 2 meses atrás"

# Fatura expirada (não foi paga antes do cancelamento)
Invoice.create!(
  subscription: subscription2,
  reference_month: 1.month.ago.beginning_of_month,
  amount_cents: plan_professional.price_cents,
  due_on: 1.month.ago.beginning_of_month + 5.days,
  status: :expired
)
puts "  - Fatura EXPIRADA (cancelou antes de pagar)"

# CENÁRIO 3: Pedro - Assinatura ativa com fatura vencida (para testar rake task)
puts "\n3️⃣ Pedro (pedro@exemplo.com):"
subscription3 = Subscription.create!(
  user: customer3,
  plan: plan_enterprise,
  status: :active,
  started_at: 3.months.ago
)
puts "  - Assinatura ATIVA (Plano Empresarial)"

# Fatura vencida há 10 dias (ainda em aberto - será marcada como expired pela rake task)
Invoice.create!(
  subscription: subscription3,
  reference_month: 1.month.ago.beginning_of_month,
  amount_cents: plan_enterprise.price_cents,
  due_on: 10.days.ago,
  status: :open
)
puts "  - Fatura VENCIDA há 10 dias (demonstrar rake expire_overdue_invoices)"

# CENÁRIO 4: Ana - Assinatura ativa sem fatura do mês (para testar geração mensal)
puts "\n4️⃣ Ana (ana@exemplo.com):"
subscription4 = Subscription.create!(
  user: customer4,
  plan: plan_professional,
  status: :active,
  started_at: 1.month.ago
)
puts "  - Assinatura ATIVA (Profissional)"
puts "  - SEM fatura do mês atual (demonstrar rake generate_monthly_invoices)"

puts "\n" + "="*60
puts "🎉 SEEDS EXECUTADAS COM SUCESSO!"
puts "="*60

puts "\n📋 RESUMO DOS CENÁRIOS CRIADOS:"
puts "--------------------------------"
puts "1. João (joao@exemplo.com) - Cliente normal"
puts "   → Assinatura ATIVA, fatura em dia"
puts ""
puts "2. Maria (maria@exemplo.com) - Caso de cancelamento"
puts "   → Assinatura CANCELADA, fatura expirada"
puts ""
puts "3. Pedro (pedro@exemplo.com) - Fatura vencida"
puts "   → Assinatura ATIVA, fatura VENCIDA há 10 dias"
puts "   → Use: rails subscriptions:expire_overdue_invoices"
puts ""
puts "4. Ana (ana@exemplo.com) - Sem fatura do mês"
puts "   → Assinatura ATIVA, sem fatura do mês atual"
puts "   → Use: rails subscriptions:generate_monthly_invoices"

puts "\n🔑 CREDENCIAIS:"
puts "--------------"
puts "Admin: admin@exemplo.com / senha123"
puts "Todos customers: senha123"

puts "\n🚀 COMANDOS ÚTEIS PARA DEMONSTRAÇÃO:"
puts "------------------------------------"
puts "# Ver faturas vencidas e marcar como expiradas:"
puts "rails subscriptions:expire_overdue_invoices"
puts ""
puts "# Gerar faturas mensais para assinaturas ativas:"
puts "rails subscriptions:generate_monthly_invoices"
puts ""
puts "# Executar rotina mensal completa:"
puts "rails subscriptions:monthly_routine"

puts "\n📌 API TOKENS:"
puts "--------------"
puts "Admin: #{admin.api_token}"
puts "João: #{customer1.api_token}"
