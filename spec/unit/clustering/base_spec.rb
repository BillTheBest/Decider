# encoding: UTF-8
require File.dirname(__FILE__) + "/../../spec_helper"

describe Clustering::Base do
  
  before do
    @clusterer = Clustering::Base.new { |d| d.plain_text }
  end
  
  it "should create training set named :corpus" do
    @clusterer.corpus.should be_an_instance_of(TrainingSet)
    @clusterer.corpus.name.should == "corpus"
  end
  
  it "should add documents to the training set via #<<(doc text)" do
    @clusterer.corpus.should_receive(:<<)
    @clusterer << "some text"
  end
  
  it "should add named documents to the training set via #push" do
    @clusterer.corpus.should_receive(:push).with(:the_doc_name, "and its text")
    @clusterer.push(:the_doc_name, "and its text")
  end
  
  it "should invalidate the cache when adding a document" do
    @clusterer.should_receive(:invalidate_cache)
    @clusterer << "some text"
  end
  
  it "should return the vector representation of all documents" do
    @clusterer.push(:quick_brown, "the quick brown").push(:brown_fox, "brown fox jumped over")
    @clusterer.push(:lazy_dog, "lazy dog").push(:over_the, "over the quick brown dog")
    index_of = @clusterer.__send__(:token_indices)
    #p @clusterer.vectors
    @clusterer.vectors["quick_brown"].length.should == 8
    expected_vector = Array.new(8, 0)
    %w{over the quick brown dog}.each {|word| expected_vector[index_of[word]] = 1}
    @clusterer.vectors["over_the"].should == expected_vector
  end
  
  it "should create a node tree from the documents in the training set" do
    @clusterer << "some text" << "some more text" << "even more text" << "yet more"
    @clusterer.tree.should be_an_instance_of Clustering::Tree
    @clusterer.root_node.should be_an_instance_of Clustering::Node
    @clusterer.root_node.should have(2).children
    @clusterer.root_node.children.each { |c| c.should have(2).children }
  end
  
  it "should name the nodes in the tree with document names" do
    @clusterer.push(:a_named_doc, "should mean a named node")
    @clusterer.root_node.children.first.name.should == "a_named_doc"
  end
  
end
