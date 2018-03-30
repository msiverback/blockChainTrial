require 'json'
require 'digest'

class Transaction

  attr_reader :transaction
  
  def initialize(sender: 0, recipient: 0, amount: 0)
    @transaction = Hash.new()
    @transaction[:sender] = sender
    @transaction[:recipient] = recipient
    @transaction[:amount] = amount
  end
  
end

class Block
  attr_reader :index
  attr_reader :proof
  attr_reader :previousHash
  attr_reader :timeStamp
  attr_reader :transactions    
  
  def initialize(index: 0, proof: 0, previousHash: 0)
    @index = index
    @proof = proof
    @previousHash = previousHash
    @timeStamp = Time.now.strftime('%s')
    @transactions = []
  end
    
  def newTransaction(transaction)
    @transactions.push(transaction)
  end

  def hash256
    sha256 = Digest::SHA256.new
    sha256.hexdigest to_s_for_hash
  end

  private
  def to_s_for_hash
    "#{@index}#{@proof}#{@previousHash}#{@timeStamp}"
  end
end

class BlockChain
  attr_reader :lastBlock
  attr_reader :chain
  attr_reader :currentTransactions
  
  def initialize
    @currentTransactions = []
    @chain = [Block.new(index: 0, proof: 100, previousHash: 1)]
    @lastBlock = @chain.last
  end
    
  def newBlock(proof: 0, previousHash: 0)
    return unless validateProof(@lastBlock.proof, proof)
    block = Block.new(index: @chain.length, proof: proof, previousHash: previousHash)
    block.newTransaction(@currentTransactions)
    @currentTransactions = []
    @chain.push(block)
    @lastBlock = @chain.last
  end

  def newTransaction(sender: 0, recipient: 0, amount: 0)
    transaction = Transaction.new(sender: sender, recipient: recipient, amount: amount)
    @currentTransactions.push(transaction)
    @chain.length + 1
  end

  def validateProof(oldProof, newProof)
    sha256 = Digest::SHA256.new
    hexString = sha256.hexdigest (oldProof * newProof).to_s
    return hexString =~ /dad$/
  end
  
end
