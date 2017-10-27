RSpec.describe Hyrax::Statistics::FileSets::ByFormat, :clean_repo do
  describe ".query" do
    let(:fs1) { create_for_repository(:file_set, mime_type: 'text/plain', format_label: ["plain text"]) }
    let(:fs2) { create_for_repository(:file_set, mime_type: 'image/jpg', format_label: ["JPEG image"]) }
    let(:fs3) { create_for_repository(:file_set, mime_type: 'image/tiff', format_label: ["TIFF image"]) }
    let(:fs4) { create_for_repository(:file_set, mime_type: 'image/jpg', format_label: ["JPEG image"]) }

    subject { described_class.query }

    it "is a list of categories" do
      expect(subject).to eq [{ label: 'jpg (JPEG image)', data: 2 },
                             { label: 'plain (plain text)', data: 1 },
                             { label: 'tiff (TIFF image)', data: 1 }]
      expect(subject.first.label).to eq 'jpg (JPEG image)'
      expect(subject.first.value).to eq 2
    end
  end
end
