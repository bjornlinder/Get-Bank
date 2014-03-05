require 'sinatra'
require 'csv'
require 'pry'
require 'Date'

get '/accounts/:account' do
#   
end

def import_shit(file_name)
  file_data = []
  CSV.foreach(file_name, headers: true) do |row|
    file_data << row.to_hash 
  end
  file_data
end

class BankAccount
  #attr :balance,
  attr_reader :starting_balance, :ending_balance
  def initialize(account_name)
    @balance = []
    @account_transactions = []
    @account_name = account_name
    @balance = import_shit('balances.csv')
    @balance.each do |account|
      if account["Account"] == @account_name
        @starting_balance = account["Balance"].to_f
      end
    end
    transactions = import_shit('bank_data.csv')
    transactions.each do |transaction|       
      if transaction["Account"] == account_name
        transaction.delete("Account")
        @account_transactions << BankTransaction.new(transaction)
        #print @account_transactions
      end
    end
  end
  
  def ending_balance
    @starting_balance - 0 #tally of banking account values
  end
  def summary
    transaction_summaries = []
    binding.pry
    transaction_summaries = @account_transactions.sort {|transaction1,transaction2| DateTime.strptime(transaction1.summary['Date'],format='%_m,%-d,%Y')<=>DateTime.strptime(transaction2.summary['Date'],format='%_m,%-d,%Y')}      
      
      # puts transaction_class.summary
      # puts transaction_class.debit?
      puts transaction_summaries
      return transaction_summaries
      #@account_transactions.each do |transaction|
      #  transaction["Date"]
         #in chronological order
  end
end

class BankTransaction# < BankAccount
  attr_reader :transaction, :summary
  
  def initialize(transaction)
    @summary = transaction
    #@transaction.each do |keys, values|
     # @summary = "#{keys} "
      
    #end
    #date,amount,description
  end

  def debit? () @summary["Amount"].to_i > 0 end
  def credit? () @summary["Amount"].to_i < 0 end
  
end

Business_Checking = BankAccount.new("Business Checking")
Business_Checking.summary
puts Business_Checking.ending_balance
Business_Checking.starting_balance
