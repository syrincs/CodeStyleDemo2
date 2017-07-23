class Admin::ContactsController < Admin::BaseController

  def index
    @contacts = Contact.ordered.page(params[:page])
  end

  def destroy
    contact = Contact.destroy(params[:id])
    redirect_to admin_contacts_path, notice: 'Contact has been deleted sucessfully'
  end

  private

  def authorize_user
    authorize! :read, :admin_dashboard
  end

  def new_message_params
    params.permit(:type, :recipient_id, :body, :subject)
  end

  def message_params
    params.require(:admin_message).permit(:body, :type, :recipient_id, :subject)
  end
end
