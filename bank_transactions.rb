require 'sinatra'
require 'csv'
require 'pry'
require 'Date'

set :views, File.dirname(__FILE__) + '/views'
set :public_folder, File.dirname(__FILE__) + '/public'

get '/accounts/:account' do
  Business_Checking = BankAccount.new(params[:account])
  erb :account
end

def import_shit(file_name, account)
  file_data = []
  CSV.foreach(file_name, headers: true) do |row|
    file_data << row.to_hash if row.to_hash["Account"] == account
  end
  file_data
end

def filter (array, &block)
  array.each do |account|
    if account["Account"] == account_name
      yield(account)
    end
  end
end

class BankAccount
  attr_reader :starting_balance, :ending_balance, :summaries, :account_name
  def initialize(account_name)
    @account_name = account_name
    @summaries = []
    @balance = []
    @account_transactions = []
    @account_name = account_name
    accounts = import_shit('balances.csv', account_name)
    transactions = import_shit('bank_data.csv', account_name)
    
    filter(accounts) do |account|
      @starting_balance = account["Balance"].to_f #trouble?
    end
    
    filter(transactions) do |transaction|
      transaction.delete("Account")
      @account_transactions << BankTransaction.new(transaction)
    end

  end
  
  def ending_balance
    difference = 0
    @account_transactions.each do |transaction|
        difference -= transaction.summary["Amount"].to_i 
    end
    @ending_balance = @starting_balance - difference 
  end
  def summary
    @account_transactions.sort {|transaction1,transaction2| DateTime.strptime(transaction2.summary['Date'],format='%m/%d/%Y')<=>DateTime.strptime(transaction1.summary['Date'],format='%m/%d/%Y')}      
  end
end

class BankTransaction
  attr_reader :transaction, :summary
  
  def initialize(transaction)
    @summary = transaction
  end

  def debit? () @summary["Amount"].to_i > 0 end
  def credit? () @summary["Amount"].to_i < 0 end
  
end
