classdef Vocabulary < handle
    properties
        words = {};
    end
    
    methods
        function add_word(self, word, audio_signals)
            new_word = Word(word);
            % Concatenate and train
            new_word.train(extract_features(cell2mat(audio_signals)'));
            self.words.(char(word)) = new_word;
        end
        
        function prediction = recognize(self, audio_signal)
            max_likelihood = -Inf;
            likelihoods = [];
            x = extract_features(cell2mat(audio_signal));
            
            for word = fieldnames(self.words)'
                likelihood = self.words.(char(word)).log_likelihood(x);
                likelihoods = [likelihoods likelihood]; %#ok<AGROW>
                
                if likelihood > max_likelihood
                    max_likelihood = likelihood;
                    prediction = word;
                end
            end            
             if isequal(char(prediction), 'fall')
            display(sprintf('Recognized sound as fall!'));
            elseif isequal(char(prediction), 'fallbath')
            display(sprintf('Recognized sound as fall!'));
            else
            display(sprintf('Recognized sound as nonfall!'));
             end
        end
        
        function prediction = recognizeTest(self, audio_signal)
            max_likelihood = -Inf;
            likelihoods = [];
            x = extract_features(audio_signal);
            disp(x);
            
            for word = fieldnames(self.words)'
                likelihood = self.words.(char(word)).log_likelihood(x);
                likelihoods = [likelihoods likelihood]; %#ok<AGROW>

                if likelihood > max_likelihood
                    
                        max_likelihood = likelihood;
                        prediction = word;
                end
            end
            
            
            global count
             if isequal(char(prediction), 'fall')
            display(sprintf('%d Recognized sound as fall! ',count));
            elseif isequal(char(prediction), 'fallbath')
            display(sprintf('%d Recognized sound as fall! ',count));
            else
            display(sprintf('%d Recognized sound as nonfall! ',count));
             end
            d = datetime;
            display(sprintf(char(d)));
            display(sprintf('\n'));

        end
        
        function predicted_word_labels = mcr(self, train_audio_signals, train_word_labels, test_audio_signals)
%             [unique_word_labels, ~, indices] = unique(train_word_labels);
% 
%             for i = 1:length(unique_word_labels)
%                 display(sprintf('Adding %s...', char(unique_word_labels(i))))
%                 self.add_word(unique_word_labels(i), train_audio_signals(indices == i))
%             end
            
            predicted_word_labels = {};
            for test_audio_signal = test_audio_signals'
                predicted_word_labels(end + 1) = self.recognize(test_audio_signal); %#ok<AGROW>
            end
            predicted_word_labels = predicted_word_labels';
        end
        
        function train(self, train_audio_signals, train_word_labels, test_audio_signals)
            [unique_word_labels, ~, indices] = unique(train_word_labels);

            for i = 1:length(unique_word_labels)
                display(sprintf('Adding %s...', char(unique_word_labels(i))))
                self.add_word(unique_word_labels(i), train_audio_signals(indices == i))
            end

        end
        
        function predicted_word_labels = test(self, test_audio_signals)
                predicted_word_labels = self.recognizeTest(test_audio_signals);

        end
    end
    
end