class RoomsController < ApplicationController
   
before_action :set_room, only: [:show, :edit, :update] 
before_action :authenticate_user!, except: [:show]
before_action :require_same_user, only: [:edit, :update]

    def index
        @rooms = current_user.rooms   
    end
    
    def new
        @room = current_user.rooms.build   
    end
    
    def create
        @room = current_user.rooms.build(room_params)
     if @room.save
         if params[:images]
             params[:images].each do |i|
                 @room.photos.create(image: i)
             end
         end
         @photos = @room.photos
         redirect_to edit_room_path(@room), notice:"Your listing was successfully put online"
     else
       render :new
     end  
    end
  
  def show 
    @photos = @room.photos
    @reviews = @room.reviews
     
    if current_user
          @booked = Reservation.where("room_id = ? AND user_id = ?", @room.id, current_user.id).present?
          @hasReview = @reviews.find_by(user_id: current_user.id)
    end
  end
  
  def edit 
      @photos = @room.photos
  end
  
  def update 
      if @room.update(room_params)
         if params[:images]
             params[:images].each do |i|
                 @room.photos.create(image: i)
             end
         end
         @photos = @room.photos
          redirect_to edit_room_path(@room), notice:"Changes saved"
      else
          render :edit
      end
  end
    
private 
  def set_room
      @room = Room.find(params[:id])
  end
  
  def room_params
      params.require(:room).permit(:home_type, :room_type, :accomodate, 
      :bed_room, :bath_room, :listing_name, :summary, :address, :is_wifi, 
      :is_tv, :is_closet, :is_shampoo, :is_breakfast, :is_heating, :is_air, 
      :is_kitchen, :price, :active)
  end
  
  def require_same_user
     if current_user.id != @room.user_id
         flash[:danger] = "You do not have the permission to edit this page"
         redirect_to root_path
     end
  end
end
    
