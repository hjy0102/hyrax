module Sipity
  RSpec.describe Workflow, type: :model, no_clean: true do
    context 'class configuration' do
      subject { described_class }
      its(:column_names) { is_expected.to include('name') }
    end

    subject { create(:workflow, name: 'ETD Workflow') }
    it { is_expected.to belong_to(:permission_template) }

    context '#initial_workflow_state' do
      it 'will create a state if one does not exist' do
        expect { subject.initial_workflow_state }
          .to change { subject.workflow_states.count }.by(1)
      end
    end

    context '.activate!' do
      let!(:permission_template) { create(:permission_template) }
      let!(:other_permission_template) { create(:permission_template) }
      let!(:active_workflow) { create(:workflow, active: true, permission_template_id: permission_template.id) }
      it 'raises an exception on a mismatch' do
        expect do
          described_class.activate!(permission_template: other_permission_template, workflow_id: active_workflow.id)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
      it 'toggles current active workflows for the permission_template' do
        active_workflow_wrong_template = create(:workflow, active: true, permission_template_id: other_permission_template.id)
        inactive_workflow = create(:workflow, permission_template_id: permission_template.id)

        described_class.activate!(permission_template: permission_template, workflow_id: inactive_workflow)
        expect(inactive_workflow.reload).to be_active
        expect(active_workflow.reload).not_to be_active
        expect(active_workflow_wrong_template.reload).to be_active
      end
    end

    context '.find_active_workflow_for_admin_set_id' do
      let(:admin_set_id) { 1234 }
      let(:permission_template) { create(:permission_template, admin_set_id: admin_set_id) }
      it 'returns the active workflow for the permission template' do
        active_workflow = create(:workflow, active: true, permission_template: permission_template)
        _inactive_workflow = create(:workflow, active: false, permission_template: permission_template)
        expect(described_class.find_active_workflow_for_admin_set_id(admin_set_id)).to eq(active_workflow)
      end

      it 'raises an exception when none exists' do
        create(:workflow, active: false, permission_template: permission_template)
        expect { described_class.find_active_workflow_for_admin_set_id(admin_set_id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
