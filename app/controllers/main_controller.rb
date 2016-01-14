class MainController < ApplicationController

  def index
    @areas = Area.mapraid
    @update = Update.find('segments')
    @nav = [{ t('nav-first-page') => '/'}]
  end
  
  def segments
    @area = CityMapraid.find(params['id'])
    @update = Update.find('segments')
    @nav = [{@area.name => "/segments/#{@area.gid}"},{@area.area.name => "/segments_area/#{@area.area.id}"},{ t('nav-first-page') => '/'}]
  end
  
  def segments_area
    @area = Area.find(params[:id])
    @update = Update.find('segments')
    @nav = [{@area.name => "#"},{ t('nav-first-page') => '/'}]
    render :segments
  end

  def admin
    @areas = Area.others
    @update = Update.find('segments')
    @nav = [{'Admin' => "#"},{ t('nav-first-page') => '/'}]
    render :index
  end
end
