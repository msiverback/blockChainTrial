require 'json'
require 'digest'
require 'date'
require 'set'
require 'openssl'

CORRECT_CHAIN = 0
ERRONEOUS_HASH = 1
ERRONEOUS_PROOF = 2
GENESIS_PROOF = 100

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
    @timeStamp = DateTime.now.strftime('%Q')
    @transactions = []
  end
    
  def newTransaction(transaction)
    @transactions.push(transaction)
  end

  def sha256
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

  def nodes
    @fakingDistribution.keys
  end
  
  def initialize
    @currentTransactions = []
    @chain = [Block.new(index: 0, proof: GENESIS_PROOF, previousHash: 1)]
    @lastBlock = @chain.last
    @fakingDistribution = {}
    @fakingDistribution["127.0.0.1"] = nil
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

  def validateChain
    @chain.each_index do |i|
      next unless i > 0
      return ERRONEOUS_PROOF unless validateProof(@chain[i-1].proof, @chain[i].proof)
      return ERRONEOUS_HASH unless (@chain[i-1].sha256 == @chain[i].previousHash)
    end
    CORRECT_CHAIN
  end

  def registerNode(address: "127.0.0.1", chain: nil)
    @fakingDistribution[address] = chain
  end

  def resolveConflicts
    @fakingDistribution.each_value do |node|
      next if node == nil
      next unless node.validateChain
      if node.chain.length > @chain.length
        @chain = node.chain
        @lastBlock = @chain.last
        @currentTransactions = node.currentTransactions
        return true
      end
    end
    false
  end
  
end

class Wallet
  attr_reader :publicKey

  def initialize
    @key = OpenSSL::PKey::RSA.new(1024)
    @publicKey = @key.public_key
  end
end
