local LogSumExp, parent = torch.class('nn.LogSumExp', 'nn.Module')


function LogSumExp:__init(dim)
	self.dim = dim
end

function LogSumExp:updateOutput(input)
	self.dim = self.dim or input:dim() --default is the last dim
	-- print("lse input", input:size())
	if self.maxes == nil then
		self.maxes = torch.max(input, self.dim) --max scores along the dim
		--print(input:size())
		--print("maxes", self.maxes)
		self.score_minus_max = torch.add(input, -1, self.maxes:expandAs(input))
		self.exp_score_minus_max = torch.exp(self.score_minus_max)
		-- print("exp score minus max", self.exp_score_minus_max:size())
		self.sum_exp_score_minus_max = torch.sum(self.exp_score_minus_max, self.dim)
		self.output = torch.log(self.sum_exp_score_minus_max)
		-- print("output", self.output:size())
	else
		torch.max(self.maxes,input, self.dim)
		-- print(input:size())
		-- print("maxes", self.maxes:size())
		self.score_minus_max:add(input, -1, self.maxes:expandAs(input))
		self.exp_score_minus_max:exp(self.score_minus_max)
		self.sum_exp_score_minus_max:sum(self.exp_score_minus_max, self.dim)
		self.output:log(self.sum_exp_score_minus_max)
	end
	self.output:add(self.maxes)
	-- print("final output", self.output:size())
	return self.output
end

function LogSumExp:updateGradInput(input, gradOutput)
	self.gradInput = input:clone()
	self.gradInput:cdiv(self.exp_score_minus_max, self.sum_exp_score_minus_max:expandAs(input))
	self.gradInput:cmul(gradOutput:expandAs(input))
	return self.gradInput
end