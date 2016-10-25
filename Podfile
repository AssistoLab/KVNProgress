platform :ios, '8.0'
use_frameworks!

target 'KVNProgressDemo' do

end

target 'KVNProgressTests' do
  pod 'FBSnapshotTestCase'
  pod 'Expecta+Snapshots'
  pod 'Specta'
  pod 'Expecta'
  pod 'OCMock'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end

