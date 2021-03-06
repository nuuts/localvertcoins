class Users::OffersController < Users::BaseController

  def index
    @offers = current_user.offers.decorate
  end

  def new
    @offer = current_user.offers.build(offer_params)
    @trade_request = TradeRequest.active.find(offer_params[:trade_request_id]).decorate
  end

  def create
    service = OfferService.new(current_user)
    service.build offer_params

    if service.save!
      redirect_to public_trade_request_path(service.offer.trade_request.slug),
        notice: 'Offer successfully created. Please wait for a reply.'
    else
      redirect_to public_trade_request_path(service.offer.trade_request.slug),
        alert: 'Offer failed to create.'
    end
  end

  private

  def offer_params
    params.require(:offer).permit(:trade_request_id, :message)
  end

  def set_section
    @section = :offers
  end
end
