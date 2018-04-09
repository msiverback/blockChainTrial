require_relative '../src/blockchain.rb'
require 'pp'
require 'date'

describe Block do

  describe "#initialize" do
    context "when given the input index, proof and previousHash " do
      StartTime = DateTime.now.strftime('%!')
      block = Block.new(index: 0, proof: 1, previousHash: 2)
      it "shall initialize a block" do
	expect(block.index).to eql(0)
  	expect(block.proof).to eql(1)
  	expect(block.previousHash).to eql(2)
      end
      it "shall give timeStamp between Start and now" do
        expect(block.timeStamp).to be_between(StartTime, DateTime.now.strftime('%Q'))
      end	        
    end        
  end
  
  describe "#newTransaction" do 
    block = Block.new(index: 0, proof: 1, previousHash: 2)
    context "when a new transaction is added" do
      it "shall be stored in the block" do
        block.newTransaction(Transaction.new(sender: 3, recipient: 4, amount: 5))
        expect(block.transactions.length).to eql(1)
        expect(block.transactions.last.transaction[:sender]).to eql(3)
        expect(block.transactions.last.transaction[:recipient]).to eql(4)
        expect(block.transactions.last.transaction[:amount]).to eql(5)
      end
    end
    context "when given a second transaction" do
      it "shall also be stored in the block" do
        block.newTransaction(Transaction.new(sender: 6, recipient: 7, amount: 8))
        expect(block.transactions.length).to eql(2)
        expect(block.transactions.last.transaction[:sender]).to eql(6)
        expect(block.transactions.last.transaction[:recipient]).to eql(7)
        expect(block.transactions.last.transaction[:amount]).to eql(8)                
      end
    end            
  end
    
  describe "#sha256" do
    it "shall return a stable hash" do
      # I can be unlucky with the milliseconds but nevermind
      block = Block.new(index: 0, proof: 1, previousHash: 2)
      block2 = Block.new(index: 0, proof: 1, previousHash: 2)
      expect(block.sha256).to eql(block2.sha256)
    end
  end
end

describe BlockChain do
  Names = ["alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta"]
  #####################################################3
  # some helper functions
  def mineNextProof(blockChain, oldProof)
    newProof = oldProof + 1
    while not blockChain.validateProof(oldProof, newProof) do
      newProof += 1
    end
    newProof
  end

  def addNewBlockToChain(index, oldProof, blockChain)
    blockChain.newTransaction(sender: 0, recipient: Names[index], amount: 1)
    newProof = mineNextProof(blockChain, oldProof)
    blockChain.newBlock(proof: newProof, previousHash: blockChain.lastBlock.sha256)
    newProof
  end
  
  def getNewBlockChain(nofBlocks: 1)
    blockChain = BlockChain.new
    newProof = 100
    0.upto(nofBlocks - 2) do |i|
      newProof = addNewBlockToChain(i, newProof, blockChain)
    end
    blockChain
  end
  
  #####################################################3
  # tests
  describe "#initialize and lastblock" do
    context "a new block chain" do
      it "shall store genesis block in lastBlock" do
	blockChain = BlockChain.new
        expect(blockChain.lastBlock).to_not eql(nil)
	expect(blockChain.lastBlock).to eql(blockChain.chain.first)
        expect(blockChain.lastBlock.proof).to eql(GENESIS_PROOF)
      end
    end            
  end
  
  describe "#chain" do
    blockChain = BlockChain.new
    it "shall also store the genesis block" do
      expect(blockChain.chain.length).to eql(1)
      expect(blockChain.chain.first.proof).to eql(GENESIS_PROOF)
      expect(blockChain.chain.first.previousHash).to eql(1)
      expect(blockChain.chain.first.index).to eql(0)
    end
  end

  describe "#validateProof" do
    context "if the value x ends with hex value dad" do
      it "shall return true" do
        blockChain = BlockChain.new
        newProof = mineNextProof(blockChain, GENESIS_PROOF)
        expect(newProof).to eql (4104)
      end
    end
  end

  describe "#newBlock" do
    it "shall add a new block to the chain" do
      blockChain = BlockChain.new 
      blockChain.newBlock(proof: 4104, previousHash: 10)
      expect(blockChain.chain.length).to eql(2)
      expect(blockChain.chain[1].proof).to eql(4104)
      expect(blockChain.chain[1].previousHash).to eql(10)
      expect(blockChain.chain[1].index).to eql(1)
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
    context "when given correct proof for the third block" do
      it "shall add that block and the previousHash shall be correct" do
        blockChain = getNewBlockChain(nofBlocks: 3)
        expect(blockChain.chain.length).to eql(3)
        expect(blockChain.lastBlock.previousHash).to eql (blockChain.chain[1].sha256)
      end
    end
  end

  describe "#validateChain" do
    context "when examining a correct chain" do
      it "shall return CORRECT_CHAIN" do
        blockChain = getNewBlockChain(nofBlocks: 5)
        expect(blockChain.validateChain).to eql(CORRECT_CHAIN)
      end
    end
    context "when a block has been replaced (new time=>hash mismatch)" do
      it "shall return ERRONEOUS_HASH" do
        blockChain = getNewBlockChain(nofBlocks: 5)
        sleep(0.1)
        blockChain.chain[1] = Block.new(index: 1,
                                        proof: 4104,
                                        previousHash: blockChain.chain.first.sha256)
        expect(blockChain.validateChain).to eql(ERRONEOUS_HASH)
      end
    end
    context "when a block has an erroneous proof" do
      it "shall return ERRONEOUS_PROOF" do
        blockChain = getNewBlockChain(nofBlocks: 5)
        blockChain.chain[4] = Block.new(index: 4,
                                        proof: 4104,
                                        previousHash: blockChain.chain[3].sha256)
        expect(blockChain.validateChain).to eql(ERRONEOUS_PROOF)
      end
    end
  end

  describe "nodes" do
    context "no matter how many times a node is added" do
      it "shall only appear once in the node list" do
        blockChain = getNewBlockChain(nofBlocks: 2)
        expect(blockChain.nodes.length).to eql(1)
        expect(blockChain.nodes.include?("127.0.0.1")).to eql(true)
        blockChain.registerNode(address: "1.1.1.1")
        expect(blockChain.nodes.length).to eql(2)
        expect(blockChain.nodes.include?("1.1.1.1")).to eql(true)
        blockChain.registerNode(address: "1.1.1.1")
        expect(blockChain.nodes.length).to eql(2)
        expect(blockChain.nodes.include?("1.1.1.1")).to eql(true)
      end
    end
    context "when two block of the same chain differ" do
      it "main block shall be updated to be authorative" do
        blockChain = getNewBlockChain(nofBlocks: 4)
        # cheat a little to get deep copy
        blockChain2 = Marshal.load(Marshal.dump(blockChain))
        addNewBlockToChain(blockChain.chain.length,
                           blockChain.lastBlock.proof, blockChain)
        blockChain.registerNode(address: "1.1.1.1", chain: blockChain2)        
        expect(blockChain.resolveConflicts).to eql(false)
        1.upto(2) do |i|
          addNewBlockToChain(blockChain2.chain.length,
                             blockChain2.lastBlock.proof, blockChain2)
        end
        expect(blockChain.resolveConflicts).to eql(true)
        expect(blockChain.chain.length).to eql(blockChain2.chain.length)
      end
    end
  end

  describe "#Wallet" do
    context "when initialized" do
      it "shall create a keypair" do
        wallet = Wallet.new
        expect(wallet.publicKey).to_not eq(nil)
      end
    end
  end
  
end
