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
        @timeStamp = Time.now
        @transactions = []
    end
    
    def newTransaction(sender: 0, recipient: 0, amount: 0)
        transaction = Hash.new()
        transaction[:sender] = sender
        transaction[:recipient] = recipient
        transaction[:amount] = amount
        @transactions.push(transaction)
    end
    
end

class BlockChain
    attr_reader :lastBlock
    attr_reader :chain
    

    def initialize
        @currentTransactions = []
        @chain = [Block.new(index: 0, proof: 100, previousHash: 1)]
        @lastBlock = @chain.last
    end
    
    def newBlock(proof: 0, previousHash: 0)
        block = Block.new(index: @chain.length, proof: proof, previousHash: previousHash)
        @chain.push(block)
        @lastBlock = @chain.last
    end
    
end
