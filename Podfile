platform :ios, '11.0'
inhibit_all_warnings!

target 'GitHubSearch' do
  use_frameworks!

  pod 'RxSwift', '~> 4.0'
  pod 'RxCocoa', '~> 4.0'
  pod 'Moya/RxSwift'
  pod 'ReactorKit'

  target 'GitHubSearchTests' do
    inherit! :search_paths

    pod 'Quick'
    pod 'Nimble'
    pod 'Stubber'
  end
end
