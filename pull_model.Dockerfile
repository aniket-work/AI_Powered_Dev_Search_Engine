# syntax = docker/dockerfile:1.4

# Stage 1: OLLama Build Environment
# We start with the OLLama image to obtain tools for downloading models
FROM ollama/ollama:latest AS ollama

# Stage 2: Minimal Babashka Runtime Environment
# Switch to a lightweight Babashka image for efficient execution of our Clojure script
FROM babashka/babashka:latest

# Copy the 'ollama' binary from the build stage
# This is the only dependency required for our model download script
COPY --from=ollama /bin/ollama ./bin/ollama

# Copy the Clojure script responsible for model downloading logic
COPY <<EOF pull_model.clj
(ns pull-model
  (:require [babashka.process :as process]
            [clojure.core.async :as async]))

(try
  (let [llm (get (System/getenv) "LLM")             ; Get the desired LLM model from the environment
        url (get (System/getenv) "OLLAMA_BASE_URL")] ; Get the base URL for OLLama interaction
    (println (format "pulling ollama model %s using %s" llm url))

    (if (and llm url (not (#{"gpt-4" "gpt-3.5" "claudev2"} llm))) ; Check if necessary conditions are met

      ;; Simplified 'ollama pull' call (adjust OLLAMA_HOST creation if needed)
      ;; TODO: Improve progress display when running from Docker Compose
      (let [done (async/chan)]
        (async/go-loop [n 0]                         ; Periodically print progress-like output
          (let [[v _] (async/alts! [done (async/timeout 5000)])]
            (if (= :stop v) :stopped (do (println (format "... pulling model (%ss) - will take several minutes" (* n 10))) (recur (inc n))))))
        (process/shell {:env {"OLLAMA_HOST" url}    ; Execute 'ollama pull' with the OLLAMA_HOST
                        :out :inherit :err :inherit}
                       (format "bash -c './bin/ollama show %s --modelfile > /dev/null || ./bin/ollama pull %s'" llm llm))
        (async/>!! done :stop))                    ; Signal completion

      (println "OLLAMA model only pulled if both LLM and OLLAMA_BASE_URL are set and the LLM model is not gpt")))
  (catch Throwable _ (System/exit 1)))             ; Error handling
EOF

# Set the default command to run the Clojure script using Babashka
ENTRYPOINT ["bb", "-f", "pull_model.clj"]