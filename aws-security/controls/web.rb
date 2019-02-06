
content = inspec.profile.file("output.json")
params = JSON.parse(content)

vpc_id = params['main_vpc_id']['value']
dmz_vpc_id = params['dmz_vpc_id']['value']
aws_instance_web_public_ip = params['aws_instance_web_public_ip']['value']

control "web-1.0" do                                # A unique ID for this control
  impact 1.0                                        # Just how critical is
  title "Web Sanity Check"                          # Readable by a human
  desc "Text should include the words 'hello world'." # Optional description

  describe http("https://" + aws_instance_web_public_ip) do
    its('status') { should cmp 200 }
  end
end
