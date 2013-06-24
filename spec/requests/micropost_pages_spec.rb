require 'spec_helper'

describe "Micropost Pages" do

  subject { page }
  
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }
  
  describe "micropost creation" do
    before { visit root_path }
    
    describe "with invalid information" do
      # Do not fill in the form and post
      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)  
      end
    end
    
    describe "with valid information" do
      before { fill_in 'micropost_content', with: "Lorem ipsum" }
      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
    end
    
  end
  
  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end
  end
    
  describe "micropost delete of another user" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          user.follow!(other_user)
          FactoryGirl.create(:micropost, user: other_user, content: "Foo")
          visit root_path 
        end
 
        it { should have_content("Foo") }
        it { should_not have_link('delete') }
  end

  describe "pagination" do
      before(:all) { 31.times  { FactoryGirl.create(:micropost, user: user, content: "Foo") } }
      after(:all)  { Micropost.delete_all }   
      
      before { visit root_path }
      
      it { should have_selector('div.pagination') } 
      
      it { should have_content("31 microposts") }
     
      it "should list each micropost" do
          Micropost.paginate(page: 1).each do |micropost|
            page.should have_selector("li##{micropost.id}", text: micropost.content)
          end
      end
        
  end
end
