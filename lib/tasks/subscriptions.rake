namespace :subscriptions do
  desc "Gera faturas mensais para todas as assinaturas ativas"
  task generate_monthly_invoices: :environment do
    puts "Iniciando geração de faturas mensais..."
    GenerateMonthlyInvoicesJob.perform_now
    puts "Processo concluído!"
  end

  desc "Marca faturas vencidas como expiradas"
  task expire_overdue_invoices: :environment do
    puts "Verificando faturas vencidas..."
    ExpireOverdueInvoicesJob.perform_now
    puts "Processo concluído!"
  end

  desc "Executa rotinas mensais (gerar faturas e expirar vencidas)"
  task monthly_routine: :environment do
    Rake::Task["subscriptions:generate_monthly_invoices"].invoke
    Rake::Task["subscriptions:expire_overdue_invoices"].invoke
  end
end
