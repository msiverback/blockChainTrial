require_relative '../src/blockchain.rb'
require 'pp'
describe Block do

  describe "#initialize" do
    context "given the input index, proof and previousHash, new " do
      StartTime = Time.now.strftime('%s')
      block = Block.new(index: 0, proof: 1, previousHash: 2)
      it "shall initialize the block" do
	expect(block.index).to eql(0)
  	expect(block.proof).to eql(1)
  	expect(block.previousHash).to eql(2)
      end
      it "shall have a timeStamp between Start and now" do
        expect(block.timeStamp).to be_between(StartTime, Time.now.strftime('%s'))
      end	        
    end        
  end
  
  describe "#newTransaction" do 
    block = Block.new(index: 0, proof: 1, previousHash: 2)
    context "a new transaction" do
      it "shall be stored in the block" do
        block.newTransaction(Transaction.new(sender: 3, recipient: 4, amount: 5))
        expect(block.transactions.length).to eql(1)
      end
      it "shall store the specified input" do
        expect(block.transactions.last.transaction[:sender]).to eql(3)
        expect(block.transactions.last.transaction[:recipient]).to eql(4)
        expect(block.transactions.last.transaction[:amount]).to eql(5)
      end
    end
    context "a second transaction" do
      it "shall also be stored in the block" do
        block.newTransaction(Transaction.new(sender: 6, recipient: 7, amount: 8))
        expect(block.transactions.length).to eql(2)
        expect(block.transactions.last.transaction[:sender]).to eql(6)
        expect(block.transactions.last.transaction[:recipient]).to eql(7)
        expect(block.transactions.last.transaction[:amount]).to eql(8)                
      end
    end            
  end
    
  describe "#hash256" do
    it "shall sort the block and return the hash (no real check)" do
      block = Block.new(index: 0, proof: 1, previousHash: 2)
      hash = block.hash256
      expect(block.hash256).to_not eql(0)
      expect(block.hash256).to eql(hash)
    end
  end
end

describe BlockChain do
  describe "#initialize and lastblock" do
    context "a new block chain" do
      it "shall contain the genesis block" do
	blockChain = BlockChain.new
	expect(blockChain.lastBlock).to_not eql(nil)
      end
    end            
  end
  describe "#chain" do
    blockChain = BlockChain.new
    context "chain call on new chain" do
      it "shall return the genesis block" do
	expect(blockChain.chain.length).to eql(1)
        expect(blockChain.chain.first.proof).to eql(100)
        expect(blockChain.chain.first.previousHash).to eql(1)
        expect(blockChain.chain.first.index).to eql(0)
      end
    end
  end

  describe "#validateProof" do
    context "if the value x ends with hex value dad" do
      it "shall return true" do
        blockChain = BlockChain.new
        newProof = 1
        while not blockChain.validateProof(100, newProof) do
          newProof += 1
        end
        expect(newProof).to eql (4104)
      end
    end
  end

  describe "#newBlock" do
    context "a newBlock " do
      it "shall add a new block to the chain" do
        blockChain = BlockChain.new 
        blockChain.newBlock(proof: 4104, previousHash: 10)
	expect(blockChain.chain.length).to eql(2)
        expect(blockChain.chain[1].proof).to eql(4104)
        expect(blockChain.chain[1].previousHash).to eql(10)
        expect(blockChain.chain[1].index).to eql(1)
      end
    end
  end
  
  describe "#newTransaction" do
    it "shall return the next index" do
      blockChain = BlockChain.new
      nextIndex = blockChain.newTransaction(sender: 33, recipient: 44, amount: 123)
      expect(blockChain.currentTransactions.length).to eql(1)
      expect(nextIndex).to eql(2)
    end
  end

  describe "mining" do
    context "you find the correct proof for the third block" do
      blockChain = BlockChain.new
      blockChain.newTransaction(sender: 0, recipient: "Martin", amount: 1)
      blockChain.newBlock(proof: 4104, previousHash: blockChain.lastBlock.hash256)
      newProof = 4105
      it "shall add a third block" do        
        while not blockChain.validateProof(4104, newProof) do
          newProof += 1
        end
        blockChain.newTransaction(sender: 0, recipient: "Martin", amount: 1)
        blockChain.newBlock(proof: newProof, previousHash: blockChain.lastBlock.hash256)
        expect(blockChain.chain.length).to eql(3)
        pp blockChain.chain
      end
      it "the second block hash shall match" do
        expect(blockChain.lastBlock.previousHash).to eql (blockChain.chain[1].hash256)
      end
    end
  end
end
