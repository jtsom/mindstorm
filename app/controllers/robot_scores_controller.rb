class RobotScoresController < ApplicationController

  before_action :authenticate

 respond_to :html, :xml, :json

  def new

    @team = @current_competition.teams.find params[:team_id]
    @robotscore = RobotScore.new
    respond_with(@team, @robotscore)

  end

  def index
    @team  = @current_competition.teams.find params[:team_id]
    respond_with(@team.robot_scores)
  end

  def show
    @team  = @current_competition.teams.find params[:team_id]
    respond_with(@team.robot_scores.find(params[:id]))
  end

  def create
    @team = @current_competition.teams.find(params[:team_id])
    @robotscore = @team.robot_scores.build(scores_params)
    flash[:notice] = "Robot score created" if @robotscore.save

    respond_with(@team, @robotscore, :location => @team)
  end

  def edit
    @team = @current_competition.teams.find params[:team_id]
    @robotscore = @team.robot_scores.find(params[:id])
    respond_with(@team, @robotscore)
  end

  def update
    team = @current_competition.teams.find(params[:team_id])
    robot_score = team.robot_scores.find(params[:id]).update_attributes(scores_params)
    flash[:notice] = "Robot score updated" if robot_score
    respond_with(team, robot_score, :location => team)
  end

  def destroy
    @team = @current_competition.teams.find(params[:team_id])
    score = @team.robot_scores.find(params[:id])
    score.destroy
    flash[:notice] = "Robot Score Entry team #{@team.fll_number} deleted."
    redirect_to @team
  end

private
    def authenticate
      if current_competition == nil
        redirect_to root_url
      end
    end

    def scores_params
      params.require(:robot_score).permit(:rank, :total_score,  :judge_name,
      :identify,:identify_exceed, :identify2, :identify2_exceed,
      :design, :design_exceed,:design2, :design2_exceed,
      :create, :create_exceed, :create2, :create2_exceed,
      :iterate, :iterate_exceed, :iterate2, :iterate2_exceed,
      :communicate, :communicate_exceed, :communicate2, :communicate2_exceed,
       :r_gj_comments, :r_ta_comments)
    end

end
