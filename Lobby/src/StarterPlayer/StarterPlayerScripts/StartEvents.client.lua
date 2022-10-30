local ReplicatedStorage = game:GetService("ReplicatedStorage")

for _, event in ReplicatedStorage.Events:GetChildren() do
    require(event)
end