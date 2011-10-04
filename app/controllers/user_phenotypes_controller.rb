class UserPhenotypesController < ApplicationController
  before_filter :require_user

  def new
		@user_phenotype = UserPhenotype.new
		@title = "Add variation"

		respond_to do |format|
			format.html
			format.xml { render :xml => @phenotype }
		end
	end

	def create
		@user_phenotype = UserPhenotype.new(params[:user_phenotype])
		@user_phenotype.user_id = current_user.id
		@user_phenotype.phenotype_id = params[:user_phenotype][:phenotype_id]
		
		if UserPhenotype.find_by_phenotype_id_and_user_id(@user_phenotype.phenotype_id,@user_phenotype.user_id) == nil
		
  		@phenotype = Phenotype.find_by_id(params[:user_phenotype][:phenotype_id])
		
  		if @phenotype.known_phenotypes.include?(params[:user_phenotype][:variation]) == false
  		  @phenotype.known_phenotypes << params[:user_phenotype][:variation]
  	  end
  		if @user_phenotype.save
		  
  		    #check for new achievements
  		    current_user.update_attributes(:phenotype_additional_counter => (current_user.user_phenotypes.length))
  		    check_and_award_additional_phenotypes(1, "Entered first phenotype")
  		    check_and_award_additional_phenotypes(5, "Entered 5 additional phenotypes")
    			check_and_award_additional_phenotypes(10, "Entered 10 additional phenotypes")
    			check_and_award_additional_phenotypes(20, "Entered 20 additional phenotypes")
    			check_and_award_additional_phenotypes(50, "Entered 50 additional phenotypes")
    			check_and_award_additional_phenotypes(100, "Entered 100 additional phenotypes")
  			
		    
    		  @phenotype.number_of_users = UserPhenotype.find_all_by_phenotype_id(@phenotype.id).length
      	  @phenotype.save
  			  redirect_to "/phenotypes/"+@user_phenotype.phenotype_id.to_s, :notice => 'Variation successfully saved'
  		else
  			render :action => "new" 
    	end
  	else
  	  redirect_to "/phenotypes/"+@user_phenotype.phenotype_id.to_s, :notice => 'You already have a variation entered'
  	end
	end

private

def check_and_award_new_phenotypes(amount, achievement_string)
	if current_user.phenotype_creation_counter >= amount and UserAchievement.find_by_achievement_id_and_user_id(Achievement.find_by_award(achievement_string).id,current_user.id) == nil
		UserAchievement.create(:achievement_id => Achievement.find_by_award(achievement_string).id, :user_id => current_user.id)
	end
end

def check_and_award_additional_phenotypes(amount, achievement_string)
	if current_user.phenotype_additional_counter >= amount and UserAchievement.find_by_achievement_id_and_user_id(Achievement.find_by_award(achievement_string).id,current_user.id) == nil
     UserAchievement.create(:user_id => current_user.id, :achievement_id => Achievement.find_by_award(achievement_string).id)
	end
end

end